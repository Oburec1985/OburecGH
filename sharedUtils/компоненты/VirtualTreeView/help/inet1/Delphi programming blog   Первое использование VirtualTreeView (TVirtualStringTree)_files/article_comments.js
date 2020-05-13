
var current_id = 0;

function MoveCommentForm(parent_id){
	if(parent_id == current_id) return false;

	var move_from = (current_id > 0) ? "comment_" + current_id : "reply_form";
	var move_to   = (parent_id  > 0) ? "comment_" + parent_id  : "reply_form";

	var fromDiv = document.getElementById(move_from);
	var toDiv   = document.getElementById(move_to);
	
	toDiv.innerHTML   = fromDiv.innerHTML;
	fromDiv.innerHTML = "";
	
	
	var postParentId = document.getElementById("comment_form_parent_id");
	if(postParentId)
		postParentId.value = parent_id;
	
	current_id = parent_id;


	return false;
}