const navbar = document.querySelector(".navbar");

navbar.classList.add("fade-in");

navbar.style.opacity = 1;


const imageToChangeDesk = document.getElementById("LogoToChange-Desktop");
const imageToChangeTablet = document.getElementById("LogoToChange-Tablet");
const imageToChangeMobile = document.getElementById("LogoToChange-Mobile");

const LogoTXTToChangeDesk = document.getElementById("LogoText-Desktop");
const LogoTXTToChangeTablet = document.getElementById("LogoText-Tablet");


// Change the image source to the new image when scrolling down
imageToChangeDesk.src = "assets/images/logo-256-lightBG.png";
imageToChangeTablet.src = "assets/images/logo-256-lightBG.png";
imageToChangeMobile.src = "assets/images/logo-256-lightBG.png";

// Change the Text color when scrolling down
LogoTXTToChangeDesk.style.color = "#041bfe";
LogoTXTToChangeTablet.style.color = "#041bfe";

