const canvas = document.getElementById('starsCanvas');
const ctx = canvas.getContext('2d');
const canvasWidth = window.innerWidth;
const canvasHeight = window.innerHeight;
const stars = [];

canvas.width = canvasWidth;
canvas.height = canvasHeight;

function getRandomNumber(min, max) {
  return Math.random() * (max - min) + min;
}

class Star {
  constructor() {
    this.x = getRandomNumber(0, canvasWidth);
    this.y = getRandomNumber(0, canvasHeight);
    this.speed = getRandomNumber(2, 5);
    this.brightness = getRandomNumber(0.5, 1);
  }

  draw() {
    ctx.beginPath();
    ctx.fillStyle = `rgba(255, 255, 255, ${this.brightness})`;
    ctx.arc(this.x, this.y, 1, 0, Math.PI * 2);
    ctx.fill();
  }

  move() {
    this.x += this.speed;
    if (this.x > canvasWidth) {
      this.x = 0;
      this.y = getRandomNumber(0, canvasHeight);
      this.speed = getRandomNumber(0.5, 2);
      this.brightness = getRandomNumber(0.1, 3);
    }
  }
}

function createStars(numStars) {
  for (let i = 0; i < numStars; i++) {
    stars.push(new Star());
  }
}

function animate() {
  ctx.clearRect(0, 0, canvasWidth, canvasHeight);
  for (const star of stars) {
    star.draw();
    star.move();
  }
  requestAnimationFrame(animate);
}

createStars(500); // Adjust the number of stars as desired
animate();
