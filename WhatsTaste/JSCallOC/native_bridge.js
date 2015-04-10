//function callNative(method, arguments, callback))
//{
//    native.callNativeMethodArgumentsCompletionHandler(method, arguments, callback)
//}
//
//function callbackToNative(callback, arguments, callbackPlus)
//{
//    callback(arguments, callbackPlus)
//}

function updateResult(resultNumber)
{
    document.getElementById("result").innerText = resultNumber;
}

function jsSquare(number)
{
    resultNumber = number * number;
    document.getElementById("result").innerText = resultNumber
}