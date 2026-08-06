from fastapi import FastAPI, File, UploadFile
import uvicorn
from inference import predict_disease

app = FastAPI(title="AgriAssist Detector API")

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    # Read image file
    image_bytes = await file.read()

    # Run inference
    # Example hook for calling the model
    result = predict_disease(image_bytes)

    return {
        "success": True,
        "top_label": result["label"],
        "top_confidence": result["confidence"],
        "predictions": result["all_predictions"],
        "inference_ms": result["latency"]
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=7860)
