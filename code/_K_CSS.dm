#define Font_Syle "System" //Roboto Light
var/cssStyleSheetDab13 = {"<style>

body {
  background-image: url("back.png");
  color: #ffffff;
  font-family: '[Font_Syle]', sans-serif;
}
h1 {
  color: #ffffff;
  font-family: '[Font_Syle]', sans-serif;
}
nav a {
  color: #ffffff;
  font-family: '[Font_Syle]', sans-serif;
}
footer {
  color: #ffffff;
  font-family: '[Font_Syle]', sans-serif;
}
a {
font-family: '[Font_Syle]', sans-serif;
}

a:link {
    color: #FFFFFF;
    border: groove 2px #FFFFFF;
    border-radius: 64px;
}

/* visited link */
a:visited {
    color: #FFFFFF;
    border: groove 3px #333;
}

/* mouse over link */
a:hover {
    color: hotpink;
}

/* selected link */
a:active {
    color: blue;
}

</style>"}

client/script = {"<style>

h1, h2, h3, h4, h5, h6
{
	color: #00f;
}

.prefix
{
	font-weight: bold;
}

.ooc
{
	font-weight: bold;
	color: #002eb8;
}

.adminooc
{
	font-weight: bold;
	color: #b82e00;
}

.admin
{
	font-weight: bold;
	color: #00FFFF;
}

.gfartooc
{
	font-weight: bold;
	color: #0099cc;
}

.gfartadmin
{
	font-weight: bold;
	color: #996600;
}

.medal
{
	font-weight: bold;
	color: #808000;
}

.name
{
	font-weight: bold;
}

.say
{
}

.deadsay
{
	color: #5c00e6;
}

.radio
{
	color: #008000;
}

.alert
{
	color: #ff0000;
}

h1.alert, h2.alert
{
	color: #ffffff;
}
</style>"}

/*

Browse() should handle this by default.

*/