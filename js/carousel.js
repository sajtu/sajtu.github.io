let startX = 0;
let currentX = 0;
const carousel = document.querySelector('.carousel');

carousel.addEventListener('touchstart', (e) => {
  startX = e.touches[0].clientX;
  currentX = startX;
});

carousel.addEventListener('touchmove', (e) => {
  const x = e.touches[0].clientX;
  const diff = currentX - x;
  currentX = x;
  carousel.scrollLeft += diff;
});

carousel.addEventListener('touchend', () => {
  const threshold = 50; // Adjust as needed
  if (startX - currentX > threshold) {
    // Swipe left
    scrollToNextItem();
  } else if (currentX - startX > threshold) {
    // Swipe right
    scrollToPreviousItem();
  }
});

function scrollToNextItem() {
  const currentScroll = carousel.scrollLeft;
  const itemWidth = carousel.clientWidth;
  const nextItem = Math.ceil(currentScroll / itemWidth);
  carousel.scrollTo({
    left: nextItem * itemWidth,
    behavior: 'smooth'
  });
}

function scrollToPreviousItem() {
  const currentScroll = carousel.scrollLeft;
  const itemWidth = carousel.clientWidth;
  const prevItem = Math.floor(currentScroll / itemWidth);
  carousel.scrollTo({
    left: prevItem * itemWidth,
    behavior: 'smooth'
  });
}
