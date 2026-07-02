from flask import Flask, request, jsonify
import boto3

app = Flask(__name__)

table = boto3.resource(
    "dynamodb",
    region_name="us-east-1"
).Table("Customers")

@app.route("/customer", methods=["POST"])
def create_customer():
    data = request.json
    table.put_item(Item=data)
    return jsonify({"message": "Customer created"})

@app.route("/customer/<id>", methods=["GET"])
def get_customer(id):
    response = table.get_item(Key={"CustomerId": id})
    return jsonify(response.get("Item", {}))

@app.route("/customer/<id>", methods=["PUT"])
def update_customer(id):
    data = request.json

    table.update_item(
        Key={"CustomerId": id},
        UpdateExpression="SET CustomerName=:n",
        ExpressionAttributeValues={
            ":n": data["CustomerName"]
        }
    )

    return jsonify({"message": "Customer updated"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)