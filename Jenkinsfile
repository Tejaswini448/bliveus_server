pipeline {
  agent any

  environment {
    IMAGE_NAME = 'bliveus-server'
    S3_BUCKET = 'your-s3-bucket-name'                       // 🔁 Replace with your bucket name
    S3_IMAGE_KEY = 'docker-images/bliveus-server.tar'       // 🔁 Desired path in S3
    EC2_IP = '13.234.112.238'
    SSH_KEY_PATH = '/var/lib/jenkins/keys/client.pem'
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/Tejaswini448/bliveus_server.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME .'
      }
    }

    stage('Save and Upload Docker Image to S3') {
      steps {
        sh '''
          docker save $IMAGE_NAME:latest -o ${IMAGE_NAME}.tar
          aws s3 cp ${IMAGE_NAME}.tar s3://$S3_BUCKET/$S3_IMAGE_KEY
        '''
      }
    }

    stage('Deploy to EC2') {
      steps {
        sh """
          ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH ubuntu@$EC2_IP << 'EOF'
            # Download image from S3
            aws s3 cp s3://$S3_BUCKET/$S3_IMAGE_KEY /tmp/${IMAGE_NAME}.tar

            # Stop and remove existing container if running
            docker stop $IMAGE_NAME || true
            docker rm $IMAGE_NAME || true

            # Load Docker image from tarball
            docker load -i /tmp/${IMAGE_NAME}.tar

            # Run the container with environment file
            docker run -d --name $IMAGE_NAME -p 3000:3000 --env-file /home/ubuntu/backend/bliveus_server/.env $IMAGE_NAME:latest
EOF
        """
      }
    }
  }
}
