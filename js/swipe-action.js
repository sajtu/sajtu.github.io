const carousel = document.querySelector('.carousel');
const mc = new Hammer(carousel);

let position = 0;

mc.on('swipeleft', () => {
	position -= 100; // Adjust as needed to control the slide width
	if (position < -((carousel.children.length - 1) * 100)) {
		position = 0;
	}
	updateCarousel();
});

mc.on('swiperight', () => {
	position += 100; // Adjust as needed to control the slide width
	if (position > 0) {
		position = -((carousel.children.length - 1) * 100);
	}
	updateCarousel();
});

function updateCarousel() {
	carousel.style.transform = `translateX(${position}%)`;
}