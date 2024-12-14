import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import BayesianRidge
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.model_selection import train_test_split
from datasets import load_dataset
import pickle
import numpy as np
import matplotlib.pyplot as plt
import torch.nn as nn
import torch.optim as optim
import torch
from torch.utils.data import DataLoader, TensorDataset
from tqdm import tqdm
import random
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF, ConstantKernel as C

class MLP(nn.Module):
    def __init__(self, input_dim):
        super(MLP, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(input_dim, input_dim),
            nn.ELU(),
            nn.Linear(input_dim, input_dim),
            nn.ELU(),
            nn.Linear(input_dim, 2048),
            nn.ELU(),
            nn.Linear(2048, 1024),
            nn.ELU(),
            nn.Linear(1024, 1),
        )
    def forward(self, x):
        return self.model(x)

if __name__ == "__main__":
    dataset = load_dataset('stair-lab/question_difficulty_embedded-full')
    df = pd.DataFrame(dataset['train'])
    X = np.array(df['embedding'].tolist())
    Y = np.array(df['score'].tolist())
    Y = Y[np.where(Y!=0)]
    X = X[np.where(Y!=0)]
    Y = np.log(Y / (1 - Y))
    
    n_datapoints = 1053-1
    n_permutation = 24
    model_name = "BayesianRidge"
    device = "cuda:1"
    batch_size = 3840
    lr = 0.001
    max_epoch = 200

    corr_tests = []
    for i in range(10):
        print(f"cross validation iteration {i}")
        ind_train = random.sample(range(n_datapoints), int(0.8*n_datapoints))
        ind_test = list(set(list(range(n_datapoints))) - set(ind_train))
        
        ind_trains = []
        for x in ind_train:
            ind_trains.extend([x*n_permutation + j for j in range(n_permutation)])

        ind_tests = []
        for x in ind_test:
            ind_tests.extend([x*n_permutation + j for j in range(n_permutation)])

        X_train = X[ind_trains, :]
        Y_train = Y[ind_trains]
        X_test = X[ind_tests, :]
        Y_test = Y[ind_tests]
        
        if model_name == "BayesianRidge":
            model = BayesianRidge(
                alpha_1=1e-4,  # Higher value increases regularization on weights
                alpha_2=1e-4,  # Higher value increases regularization on weights
                lambda_1=1e-4, # Higher value increases regularization on noise
                lambda_2=1e-4  # Higher value increases regularization on noise
            )
            
            model.fit(X_train, Y_train)
            Y_pred_train = model.predict(X_train)
            Y_pred_test = model.predict(X_test)
            mean_predictor = np.array(Y_train).mean()

        elif model_name == "GPRegression":
            # Define the kernel: constant * RBF (radial basis function)
            kernel = C(1.0, (1e-4, 1e1)) * RBF(1.0, (1e-4, 1e1))
            
            # Initialize the Gaussian Process model
            model = GaussianProcessRegressor(kernel=kernel, alpha=1e-4, n_restarts_optimizer=10)

            # Fit the GP model
            model.fit(X_train, Y_train)

            # Make predictions
            Y_pred_train = model.predict(X_train)
            Y_pred_test = model.predict(X_test)
            mean_predictor = np.array(Y_train).mean()
            
        else:
            input_dim = len(X_train[0])
            model = MLP(input_dim).to(device)
            criterion = nn.MSELoss()
            optimizer = optim.Adam(model.parameters(), lr=lr)

            X_train = torch.tensor(X_train).to(device).float()
            Y_train = torch.tensor(Y_train).to(device).float()
            X_test = torch.tensor(X_test).to(device).float()
            Y_test = torch.tensor(Y_test).to(device).float()
            
            train_dataset = TensorDataset(X_train, Y_train)
            train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
            test_dataset = TensorDataset(X_test, Y_test)
            test_loader = DataLoader(test_dataset, batch_size=batch_size)

            pbar = tqdm(range(max_epoch))
            for _ in pbar:
                total_train_loss = 0
                model.train()
                for emb_batch, z_batch in train_loader:
                    emb_batch, z_batch = emb_batch.to(device), z_batch.to(device)
                    optimizer.zero_grad()
                    # breakpoint()
                    outputs = model(emb_batch).squeeze()
                    loss = criterion(outputs, z_batch)
                    loss.backward()
                    optimizer.step()
                    total_train_loss += loss.item()
                
                total_test_loss = 0
                model.eval()
                with torch.no_grad():
                    for emb_batch, z_batch in test_loader:
                        emb_batch, z_batch = emb_batch.to(device), z_batch.to(device)
                        outputs = model(emb_batch).squeeze()
                        loss = criterion(outputs, z_batch)
                        total_test_loss += loss.item()
                
                train_loss = total_train_loss / len(train_loader)
                test_loss = total_test_loss / len(test_loader)
                pbar.set_postfix({'train_loss': train_loss, 'test_loss': test_loss})
            
            Y_pred_train = model(X_train).cpu().detach().numpy()
            Y_pred_test = model(X_test).squeeze().cpu().detach().numpy()
            mean_predictor = Y_train.mean().cpu().detach().numpy()

            Y_train = Y_train.cpu().detach().numpy()
            Y_test = Y_test.cpu().detach().numpy()

        Y_train = 1 / (np.exp(-Y_train) + 1)
        Y_test = 1 / (np.exp(-Y_test) + 1)
        Y_pred_train = 1 / (np.exp(-Y_pred_train) + 1)
        Y_pred_test = 1 / (np.exp(-Y_pred_test) + 1)
        mean_predictor = 1 / (np.exp(-mean_predictor) + 1)
        
        mae_train = mean_absolute_error(Y_train, Y_pred_train)
        mae_test = mean_absolute_error(Y_test, Y_pred_test)
        mae_test_baseline = (abs(Y_test - mean_predictor)).mean()
    
        r2_test = r2_score(Y_test, Y_pred_test)
        corr_test_matrix = np.corrcoef(Y_test, Y_pred_test)
        corr_test = corr_test_matrix[0, 1]
        corr_tests.append(corr_test)
        
        # Print the correlation
        print(f'Correlation test: {corr_test}')        
        print(f'MAE train: {mae_train:.2f}')
        print(f'MAE test: {mae_test:.2f}')
        print(f'R2 test: {r2_test:.2f}')
        print(f'MAE test baseline: {mae_test_baseline:.2f}')

        plt.figure(figsize=(8, 8))
        plt.scatter(Y_test, Y_pred_test, alpha=0.6, edgecolors='k')
        plt.scatter(Y_train, Y_pred_train, alpha=0.6, edgecolors='r')
        plt.plot([0, 1], [0, 1], linewidth=2)
        plt.title('Scatter Plot of True vs Predicted Labels', fontsize=14)
        plt.xlabel('True Labels', fontsize=12)
        plt.ylabel('Predicted Labels', fontsize=12)
        plt.savefig(f"corr{i}", dpi=300, bbox_inches='tight')

    corr_tests = np.array(corr_test)
    print("Mean Corr Test: ", corr_test.mean())

    with open('question_diff.pkl', 'wb') as f:
        pickle.dump(model, f)
