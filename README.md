# PHE_transformer

trying out decision transformers as a Plate Heat Exchange (PHE) controller

## LINKS: 
- [Decision Transformer](https://github.com/kzl/decision-transformer)
- [HuggingFace Decision Transformer](https://github.com/huggingface/blog/blob/main/notebooks/101_train-decision-transformers.ipynb)
- [Online Decision Tranformer](https://github.com/facebookresearch/online-dt)

## Data Generation and Storage:

- MATLAB script used to generate a large dataset of simulations with varying parameters and random shifts.
- Data stored in csv file 

## Data Preprocessing in Python:

Python script used to load and preprocess the generated data from MATLAB.
- Handle any missing or invalid data points.
- Split the preprocessed data into training and validation sets and store in parquet files.

## Custom Data Collator in Python:

Adapted the existing data collator class (DecisionTransformerGymDataCollator) to work with our specific dataset.

## Training Pipeline in Python:

Training pipeline using the Hugging Face Trainer class.
- Instantiate the Decision Transformer model and the custom data collator.
- Configure the training arguments, such as the number of epochs, batch size, learning rate, and optimization settings.
- Train and store checkpoints
- Visualize training and evaluation loss and based on that chose the right checkpoint for testing.

### Testing Integration with MATLAB Simulation:
- modify the matlab script into functions for calling from python. State managed on python side, simulation (PHE state generation for each timestep) managed by matlab.
- test if the transformer works on controlling a PHE
