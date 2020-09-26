name: terraform apply
on:
  push:
    branches: [ master ]
jobs:
  apply:
    name: terraform apply
    runs-on: ubuntu-latest
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-2

      - name: terraform setup
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 0.12.24
      - id: init
        run: terraform init
      - id: apply
        run: terraform apply -auto-approve -no-color