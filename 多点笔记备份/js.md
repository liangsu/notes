
Object.assign(target, source)
用source覆盖target

stringFormat(content, args){
	let arr = [];
	if(Array.isArray(args)){
	  arr = args;
	}else{
	  arr.push(args);
	}
	for (let b = 0; b < arr.length; b++)
	  content = content.replace(RegExp("\\{" + b + "\\}", "ig"), arr[b]);
	return content
}