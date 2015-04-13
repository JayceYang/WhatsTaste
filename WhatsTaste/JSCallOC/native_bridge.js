function call_native(method, arguments, callback)
{
    alert("I am an call_native box!!" + arguments)
    native.callNativeMethodArgumentsCompletionHandler(method, arguments, callback);
}

function callback_to_native(callback, arguments, callbackPlus)
{
    alert("I am an callback_to_native box!!")
    callback(arguments, callbackPlus);
}

//function updateResult(resultNumber)
//{
//    document.getElementById("result").innerText = resultNumber;
//}
//
//function jsSquare(number)
//{
//    resultNumber = number * number;
//    document.getElementById("result").innerText = resultNumber
//}