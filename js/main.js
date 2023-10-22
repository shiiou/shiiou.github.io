
(function ($) {
    "use strict";

    
    /*==================================================================
    [ Validate ]*/
    var discord = $('.validate-input input[name="discord"]');
    var HRP = $('.validate-input input[name="HRP"]');
    var RP = $('.validate-input input[name="RP"]');
    var numero = $('.validate-input input[name="numero"]');
    var disponibilite = $('.validate-input textarea[name="disponibilite"]');
    var pkvous = $('.validate-input input[name="pkvous"]');
    var presentation = $('.validate-input textarea[name="presentation"]');


    $('.validate-form').on('submit',function(){
        var check = true;

        if($(discord).val().trim() == ''){
            showValidate(discord);
            check=false;
        }


        if($(HRP).val().trim() == ''){
            showValidate(HRP);
            check=false;
        }


        if($(RP).val().trim() == ''){
            showValidate(RP);
            check=false;
        }


        if($(numero).val().trim() == ''){
            showValidate(Numéro de téléphone);
            check=false;
        }
        
        
        if($(disponibilite).val().trim() == ''){
            showValidate(Heures de disponibilite);
            check=false;
        }

        if($(pkvous).val().trim() == ''){
            showValidate(pourquoi vous et pas un autre);
            check=false;
        }


        if($(presentation).val().trim() == ''){
            showValidate(Présentation);
            check=false;
        }

        return check;
    });


    $('.validate-form .input1').each(function(){
        $(this).focus(function(){
           hideValidate(this);
       });
    });

    function showValidate(input) {
        var thisAlert = $(input).parent();

        $(thisAlert).addClass('alert-validate');
    }

    function hideValidate(input) {
        var thisAlert = $(input).parent();

        $(thisAlert).removeClass('alert-validate');
    }
    
    

})(jQuery);