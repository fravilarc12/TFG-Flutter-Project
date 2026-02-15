def load_data(file_path):
    """
    Load data from the specified file path.
    
    Parameters:
    file_path (str): The path to the data file to be loaded.
    
    Returns:
    data: The loaded data.
    """
    import pandas as pd
    
    data = pd.read_csv(file_path)
    return data

def preprocess_data(data):
    """
    Preprocess the loaded data.
    
    Parameters:
    data: The data to be preprocessed.
    
    Returns:
    data: The preprocessed data.
    """
    # Example preprocessing steps
    data = data.dropna()  # Remove missing values
    data = data.reset_index(drop=True)  # Reset index
    return data

def save_processed_data(data, output_path):
    """
    Save the processed data to the specified output path.
    
    Parameters:
    data: The data to be saved.
    output_path (str): The path where the processed data will be saved.
    """
    data.to_csv(output_path, index=False)