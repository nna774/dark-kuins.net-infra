secret_gcs_key := gs://dark-kuins-net/itamae-secret/default
secret_path := secret/keys/default

put_secret:
	gcloud kms encrypt \
	  --plaintext-file=$(secret_path) \
	  --project=united-crane-800 \
	  --location=global \
	  --ciphertext-file=- \
	  --keyring=dark-kuins-net-infra \
	  --key=main \
	| \
	gsutil cp - $(secret_gcs_key)

get_secret:
	gsutil cp $(secret_gcs_key) - | \
	gcloud kms decrypt \
	  --ciphertext-file=- \
	  --plaintext-file=$(secret_path) \
	  --project=united-crane-800 \
	  --location=global \
	  --ciphertext-file=- \
	  --keyring=dark-kuins-net-infra \
	  --key=main

diff_secret:
	gsutil cp $(secret_gcs_key) - | \
        gcloud kms decrypt \
	  --ciphertext-file=- \
	  --plaintext-file=- \
	  --project=united-crane-800 \
	  --location=global \
	  --ciphertext-file=- \
	  --keyring=dark-kuins-net-infra \
	  --key=main \
	| \
	diff -u - $(secret_path)
