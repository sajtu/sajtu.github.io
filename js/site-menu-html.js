const siteMenuHTML = `

<div class="site-map-bar-Desktop">
	<div id="site-icon">
		<img src="assets/images/microsite-matrix-icon-outline.png" onmouseover="SiteIconHover(this);" onmouseout="SiteIconHoverOut(this)" onclick="displaySiteMap()" class="site-icon-img" alt="Site Map" height=40 width=40>
	</div>
</div>

<div class="modal" id="menu-modal">

	<div class="site-map-bar-Desktop">
		<div id="site-icon">
			<img src="assets/images/microsite-matrix-icon-solid.png" onclick="displaySiteMap()" class="site-icon-img" alt="Site Map" height=40 width=40>
		</div>
	</div>



	<div id="site-map-menu" class="site-map-menu-content">
		<div class="site-apps-menu-header">
			Switch to:
		</div>


		<div class="site-apps-box">
			<table width=100%>
				<tr><td><a href="https://github.com/sajtu"><div class="site-apps-icon"><table height=100% width=100%><td valign="middle" align="center"><img src="assets/site-menu-icons/site-256-github-icon.svg" alt="Help Center"></td></table></div></a></td></tr>
				<tr><td><div class="site-apps-label">GitHub</div></td></tr>
			</table>
		</div>



		<div class="site-apps-box">
			<table width=100%>
				<tr><td><a href="https://www.linkedin.com/in/stu8752883" target=_LinkedIn><div class="site-apps-icon-in-blue"><table height=100% width=100%><td valign="middle" align="center"><img src="assets/site-menu-icons/site-linkedin-icon-txt.svg" alt="linkedin.com/in/stu8752883"></td></table></div></a></td></tr>
				<tr><td><div class="site-apps-label">LinkedIn</div></td></tr>
			</table>
		</div>

	</div>

</div>
`;
	  
	  
document.write(siteMenuHTML);