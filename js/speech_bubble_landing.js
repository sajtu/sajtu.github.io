let messageIndex = 0; // Initialize the index for cycling through messages
let current_rotation = 0;


/* Desktop */
const greetingBubble = document.getElementById('greetingBubble');

/* Tablet */
const greetingBubbleTablet = document.getElementById('greetingBubble-Tablet');

/* Mobile */
const greetingBubbleMobile = document.getElementById('greetingBubble-Mobile');





let avatarName = "Sean";

function getGreetingMessage() {
  const currentHour = new Date().getHours();

  if (currentHour >= 4 && currentHour < 7) {
    return `Good morning. I'm <font class="speech-bubble-name">Sean</font>.`;
  } else if (currentHour >= 7 && currentHour < 12) {
    return `Good morning! I'm <font class="speech-bubble-name">Sean</font>.`;
  } else if (currentHour >= 12 && currentHour < 16) {
    return `Good Afternoon! I'm <font class="speech-bubble-name">Sean</font>.`;
  } else if (currentHour >= 16 && currentHour < 20) {
    return `Good Evening! I'm <font class="speech-bubble-name">Sean</font>.`;
  } else {
    return `Good Evening. I'm <font class="speech-bubble-name">Sean</font>.`;
  }
}

let InitialGreeting = getGreetingMessage();
greetingBubble.innerHTML = InitialGreeting;
greetingBubbleTablet.innerHTML = InitialGreeting;
greetingBubbleMobile.innerHTML = InitialGreeting;





const messages = [
  `Welcome to my personal website.`,
    
  "I'm a technology nerd, IT engineer, gamer, and technology leader.",
   
  InitialGreeting
  ];


function updateSpeechBubble() {
  greetingMessage = messages[messageIndex];

	/* Desktop */
	const greetingBubble = document.getElementById('greetingBubble');
	greetingBubble.innerHTML = greetingMessage; 

	/* Tablet */
	const greetingBubbleTablet = document.getElementById('greetingBubble-Tablet');
	greetingBubbleTablet.innerHTML = greetingMessage; 

	/* Mobile */
	const greetingBubbleMobile = document.getElementById('greetingBubble-Mobile');
	greetingBubbleMobile.innerHTML = greetingMessage; 

	messageIndex = (messageIndex + 1) % messages.length; // Cycle through messages

}

// Set the timer to update the speech bubble every 10 seconds (1000 milliseconds = 1 sec)
const interval = setInterval(updateSpeechBubble, 10000);

