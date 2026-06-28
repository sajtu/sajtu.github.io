    // JavaScript to unmute the video on hover
    const video = document.getElementById("DemoVideo");

    // Function to unmute the video
    function unmuteVideo() {
        video.muted = false;
		video.volume = 0.1;
    }

    // Add event listeners for mouseenter and mouseleave
    video.addEventListener("mouseenter", unmuteVideo);
    video.addEventListener("mouseleave", function() {
        // Mute the video again when the mouse leaves
        video.volume = 0.1;
		video.muted = true;
		
    });
