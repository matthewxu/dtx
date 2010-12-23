function showNodes() {
  // get the rootElement of the document (HTML tag)
  var rootElement = document.documentElement;

  // get the rootElement's children (HEAD and BODY tags)
  var docNodes = rootElement.childNodes;

  // show the nodeName for the children
  for (i = 0; i < docNodes.length; i++) {
    alert(docNodes[i].nodeName);
  }

  // get the table cells - this returns an array of all TD's
  var myTableCells = document.getElementsByTagName("td");
  for (i = 0; i < myTableCells.length; i++) {
    alert(myTableCells[i].nodeName);
  }
}

function changeTDNodes() {

	  // there can be many "tr" elements; just return the first/zeroth element
	  var mycurrent_row = document.getElementsByTagName("tr")[0];
	  // create a new td cell
	  mycurrent_cell = document.createElement("td");
	  // creates a text node
	  currenttext = document.createTextNode("new cell3 here");
	  // appends the text node we created into the cell <td>
	  mycurrent_cell.appendChild(currenttext);
	  // appends the cell <td> into the row <tr>
	  mycurrent_row.appendChild(mycurrent_cell);
}
