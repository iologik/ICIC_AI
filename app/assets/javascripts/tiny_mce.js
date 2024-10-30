$(function(){

    // WYSIWYG editor

    if($('body.admin_updates').length == 0) {
        tinyMCE.init({
            fontsize_formats: "8pt 9pt 10pt 11pt 12pt 26pt 36pt",
            mode: 'textarea',
            editor_selector: "tinymce_editor",
            toolbar: "fontselect fontsizeselect forecolor",
            menu: {},
            plugins: "textcolor",
            browser_spellcheck: true,
            height : "480"
        });
    } else {
        tinymce.init({
            selector: "textarea",
            plugins: [
                "advlist autolink lists link image charmap print preview hr anchor pagebreak",
                "searchreplace wordcount visualblocks visualchars code fullscreen",
                "insertdatetime media nonbreaking save table contextmenu directionality",
                "emoticons template paste textcolor colorpicker textpattern"
            ],
            toolbar1: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image",
            toolbar2: "print preview media | fontselect fontsizeselect | forecolor backcolor emoticons",
            templates: [
                {title: 'Test template 1', content: 'Test 1'},
                {title: 'Test template 2', content: 'Test 2'}
            ],
            file_picker_callback: function(callback, value, meta) {
                $("#file").click();
            },
            height : "480"
        });
    }
})
