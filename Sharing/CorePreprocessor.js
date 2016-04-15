var Prepro = function() {};

Prepro.prototype = {
run: function(arguments) {
    arguments.completionFunction({"URL": document.URL, "body": document.body.innerText, "title": document.title, "selection": window.getSelection().toString()});
}
};

var ExtensionPreprocessingJS = new Prepro;