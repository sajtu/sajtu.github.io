function createCloud(container) {
    const cloud = document.createElement('div');
    cloud.className = 'cloud-bg'; // You can change this class to 'cloud-fg' for foreground clouds
    const containerWidth = container.offsetWidth;
    const containerHeight = container.offsetHeight;

    const startX = Math.random() * (containerWidth - 100);
    const startY = Math.random() * (containerHeight - 60);
    const speed = Math.random() * 20 + 10;

    cloud.style.left = `${startX}px`;
    cloud.style.top = `${startY}px`;
    cloud.style.animationDuration = `${speed}s`;

    return cloud;
}

function getRandomNumberOfClouds() {
    return Math.floor(Math.random() * 106) + 5; // Generates a random number between 5 and 50
}

const cloudContainer = document.querySelector('.cloud-bg-container');
const numClouds = getRandomNumberOfClouds();

for (let i = 0; i < numClouds; i++) {
    const cloud = createCloud(cloudContainer);
    cloudContainer.appendChild(cloud);
}

// Create foreground clouds

function getRandomNumberOfFGClouds() {
    return Math.floor(Math.random() * 6) + 5; // Generates a random number between 5 and 50
}


const cloudFgContainer = document.querySelector('.cloud-fg-container');
const numFgClouds = getRandomNumberOfFGClouds();

for (let i = 0; i < numFgClouds; i++) {
    const cloudFg = createCloud(cloudFgContainer);
    cloudFgContainer.appendChild(cloudFg);
}



const cloudFgVContainer = document.querySelector('.cloud-fg-container-vertical');
const numFgVClouds = getRandomNumberOfFGClouds();

for (let i = 0; i < numFgVClouds; i++) {
    const cloudVFg = createCloud(cloudFgVContainer);
    cloudFgVContainer.appendChild(cloudVFg);
}
