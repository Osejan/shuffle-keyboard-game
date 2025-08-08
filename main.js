const publishableKey = "YOUR_PUBLISHABLE_KEY"; // Replace with your Roboflow publishable key
const modelName = "ant-detection-final";
const modelVersion = "1";

const video = document.getElementById("videoElement");
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

const inferEngine = new InferenceEngine();
let workerId = null;
let antPath = [];

async function setupCamera() {
  const stream = await navigator.mediaDevices.getUserMedia({
    video: { facingMode: "environment" },
    audio: false,
  });
  video.srcObject = stream;
  await new Promise((resolve) => (video.onloadedmetadata = resolve));
  canvas.width = video.videoWidth;
  canvas.height = video.videoHeight;
}

async function loadModel() {
  workerId = await inferEngine.startWorker(modelName, modelVersion, publishableKey);
  console.log("Model loaded, workerId:", workerId);
}

function drawBoundingBox(box, label, score) {
  ctx.strokeStyle = "lime";
  ctx.lineWidth = 3;
  ctx.font = "18px Arial";
  ctx.fillStyle = "lime";

  ctx.beginPath();
  ctx.rect(box[0], box[1], box[2], box[3]);
  ctx.stroke();

  ctx.fillText(`${label} (${(score * 100).toFixed(1)}%)`, box[0], box[1] > 20 ? box[1] - 5 : box[1] + 20);
}

function drawPath() {
  if (antPath.length < 2) return;
  ctx.strokeStyle = "red";
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.moveTo(antPath[0].x, antPath[0].y);
  for (let i = 1; i < antPath.length; i++) {
    ctx.lineTo(antPath[i].x, antPath[i].y);
  }
  ctx.stroke();
}

function getBoxCenter(box) {
  return {
    x: box[0] + box[2] / 2,
    y: box[1] + box[3] / 2,
  };
}

async function detectFrame() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

  const predictions = await inferEngine.infer(workerId, video);
  if (predictions && predictions.length) {
    // Filter ants only
    const ants = predictions.filter(p => p.class === "ant" && p.confidence > 0.4);

    if (ants.length > 0) {
      // Assume first detected ant is the target
      const box = ants[0].bbox; // [x, y, width, height]
      drawBoundingBox(box, "ant", ants[0].confidence);

      // Track path by center point
      const center = getBoxCenter(box);
      antPath.push(center);

      // Limit path length
      if (antPath.length > 50) {
        antPath.shift();
      }

      drawPath();
    }
  }
  requestAnimationFrame(detectFrame);
}

async function main() {
  await setupCamera();
  await loadModel();
  detectFrame();
}

main();
