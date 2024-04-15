# PHE_transformer

trying out decision transformers as a Plate Heat Exchange (PHE) controller

## LINKS: 
- [Decision Transformer](https://github.com/kzl/decision-transformer)
- [HuggingFace Decision Transformer](https://github.com/huggingface/blog/blob/main/notebooks/101_train-decision-transformers.ipynb)
- [Online Decision Tranformer](https://github.com/facebookresearch/online-dt)

### Data Generation and Storage:

- MATLAB script used to generate a large dataset of simulations with varying parameters and random shifts.
- Data stored in csv file 

### Data Preprocessing in Python:

Python script used to load and preprocess the generated data from MATLAB.
- Normalize the observation features, scale the rewards and returns, and handle any missing or invalid data points."
- Split the preprocessed data into training and validation sets.

### Custom Data Collator in Python:

Adapted the existing data collator class (DecisionTransformerGymDataCollator) to work with our specific dataset.
- Implement methods to sample batches of trajectories, pad sequences to a fixed length, and return the required tensors for training the Decision Transformer.

### Decision Transformer Model Configuration:

Defined the architecture and hyperparameters for our Decision Transformer model using pytorch.
- Specify the state dimension, action dimension, and any other model-specific settings based on our simulation data.

### Training Pipeline in Python:

Training pipeline using the Hugging Face Trainer class.
- Instantiate the Decision Transformer model and the custom data collator.
- Configure the training arguments, such as the number of epochs, batch size, learning rate, and optimization settings.
- Train and monitor the training progress and validation metrics.

### Model Evaluation and Testing:

Evaluation metrics to assess the performance of the trained Decision Transformer model (squared error between predicted and actual actions)
- Use the validation set to evaluate the model's performance and make any necessary adjustments to the model architecture or hyperparameters.
- OPTIONAL (would require incorporating the model into matlab or rewriting the PHE simulation in python)
    - Test the trained model on held-out test data or in a simulated environment to assess its generalization capabilities.

### OPTIONAL: Integration with MATLAB Simulation:
MATLAB's Python integration capabilities to directly call the trained Python model from within the MATLAB simulation.


### OPTIONAL (if simulation is half decent) Deployment and Real-time Control:

- Integrate the model with the actual Plate Heat Exchanger (PHE) system or a real-time simulation environment.
- Implement the necessary communication interfaces and control loops to enable the Decision Transformer to generate actions based on real-time observations and desired setpoints.

### OPTIONAL Iterative Refinement and Online Learning:

- Use of Online Decision Transformer
    - online learning and model adaptation, allowing the Decision Transformer to fine-tune its predictions based on the collected data
