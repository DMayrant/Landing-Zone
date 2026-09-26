import boto3 
import json 

bedrock = boto3.client("bedrock-runtime", region_name="us-east-1")

modelId = "nvidia.nemotron-nano-12b-v2"
text = "explain that CIDR 0.0.0.0/0 is open allowing public ingress for port 22 creating a security risk"

response = bedrock.converse(
    modelId=modelId,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "text": text
                }
            ]
        }
    ]
    
)

print(json.dumps(response, indent=4))

analysis = response["output"]["message"]["content"][0]["text"]
print(analysis)