import boto3
import os

# Charger les variables d'environnement depuis Kubernetes
access_key = os.getenv('AWS_ACCESS_KEY_ID')
secret_key = os.getenv('AWS_SECRET_ACCESS_KEY')
region = os.getenv('AWS_DEFAULT_REGION')

# Configurer le client SageMaker
sagemaker_client = boto3.client('sagemaker', 
                                aws_access_key_id=access_key, 
                                aws_secret_access_key=secret_key,
                                region_name=region)

# Définir les configurations du job d'entraînement
training_params = {
    'TrainingJobName': 'mlops-train-job',
    'AlgorithmSpecification': {
        'TrainingImage': '382416733822.dkr.ecr.eu-west-1.amazonaws.com/linear-learner:latest',  # IMAGE à modifier si nécessaire
        'TrainingInputMode': 'File'
    },
    'RoleArn': 'arn:aws:iam::YOUR_ACCOUNT_ID:role/SageMakerRole',  # ARN du rôle IAM avec les permissions requises
    'InputDataConfig': [
        {
            'ChannelName': 'train',
            'DataSource': {
                'S3DataSource': {
                    'S3DataType': 'S3Prefix',
                    'S3Uri': 's3://my-bucket/train-data',  # Modifier le Bucket S3 en fonction de l'environnement
                    'S3DataDistributionType': 'FullyReplicated'
                }
            },
            'ContentType': 'text/csv',
        }
    ],
    'OutputDataConfig': {
        'S3OutputPath': 's3://my-bucket/output/'  # Emplacement des résultats d'entraînement
    },
    'ResourceConfig': {
        'InstanceType': 'ml.m5.large',
        'InstanceCount': 1,
        'VolumeSizeInGB': 50
    },
    'StoppingCondition': {
        'MaxRuntimeInSeconds': 3600
    }
}

# Lancer le job d'entraînement
response = sagemaker_client.create_training_job(**training_params)
print(f"Job d'entraînement lancé : {response['TrainingJobArn']}")

