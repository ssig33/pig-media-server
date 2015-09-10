window.round = (i)=>{
  i = i*10;
  return Math.round(i)/10
}

window.size_pretty = (size)=>{
  var size = parseFloat(String(size));
  var result = size;
  if(size < 1024){
    result = `${size} Bytes`
  } else if(size < 1024*1024){
    result = `${round(size / 1024)} KB`
  } else if(size < 1024*1024*1024){
    result = `${round(size / (1024*1024))} MB`
  } else if(size < 1024*1024*1024*1024){
    result = `${round(size / (1024*1024*1024))} GB`
  }
  return result
}


window.ext = (str)=>{ return String(str).split('.').pop().toLowerCase(); }
