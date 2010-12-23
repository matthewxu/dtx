var texttop;
var textleft;

function getObj(name)
{
	if(document.getElementById(name)){
		this.obj=document.getElementById(name);
		this.style = document.getElementById(name).style;
		 
	}else{
		return;
	}
}

function moveUpDown(name,amount) {
	var myObj = new getObj(name);

	if(texttop==undefined){
		texttop = parseInt(getStyle(name,'left').replace('px',''));
	}
	texttop+=parseInt(amount);
	myObj.style.top =texttop;
}

function moveLR(name,amount) {
	var myObj = new getObj(name);
	if(textleft==undefined){
		textleft = parseInt(getStyle(name,'top').replace('px',''));
	}
	textleft += amount;
	myObj.style.left = textleft;
}


function showLike(){
    var names = document.getElementsByName('lay[]');
    var len = names.length;
    if(len>0){
        var i =0;
        for(i=0;i<len;i++){
            if(names[i].checked==true){
                return names[i].value;
            }
        }
    }
    return ;
}

function moveLRByName(amount){
	name=  showLike();
	moveLR(name,amount);
	return
}
function moveUDByName(amount){
	name= showLike();
	moveUpDown(name,amount);
	return;
}


function getStyle(id,stylename){
	elem=document.getElementById(id);
	if (elem.style[stylename])
	{	
		alert(elem.style[stylename]);
		return elem.style[stylename];
	}
	else if (elem.currentStyle)
	{
		return elem.currentStyle[stylename];
	}
	else if (document.defaultView && document.defaultView.getComputedStyle)
	{
		name = name.replace(/([A-Z])/g,"-$1");
		name = name.toLowerCase();
		var s = document.defaultView.getComputedStyle(elem,"");
		return  s.getPropertyValue(stylename);
	}
	else
	{ 
		return null;
	
	}
	

}
