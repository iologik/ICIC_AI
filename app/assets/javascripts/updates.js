$(function(){
    $('head').append('<link  href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/3.5.7/jquery.fancybox.min.css" rel="stylesheet">');
    // image uploader
    if($("body.admin_updates").length > 0) {
        var s3_image_uploader = $("#s3-image-uploader");
        var uploader = s3_image_uploader.S3Uploader({
            remove_completed_progress_bar: false,
            before_add: function(file) {
                var types = (/\.(gif|jpg|jpeg|tiff|png)$/i);
                if(types.test(file.type) || types.test(file.name)) {
                    return true;
                } else {
                    alert("Please select an image file.")
                    return false;
                }
            }
        });
        s3_image_uploader.bind("s3_uploads_start", function(e, content) {
            var image_container = $('.tox-dialog');
            image_container.css('position', 'relative');
            var shade = $('<div class="shade"></div>');
            image_container.append(shade);
        });
        s3_image_uploader.bind("s3_upload_complete", function(e, content) {
            $($('.tox-textfield')[0]).val(content.url);
            $('.shade').remove();
        });


        // addEmailSubInvestor();
    }
    $('.admin_updates img').each(function () {
        $(this).wrap($('<a/>', {
            href: $(this).attr('src'),
            class: "fancybox",
            rel: "artikel",
            "data-fancybox": "gallery"
        }));
    });

    $('.fancybox').fancybox();
});
