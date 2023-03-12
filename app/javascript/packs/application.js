// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//= require jquery
//= require jquery_ujs

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

window.competition_visibility = function() {
    var value = $('[id*="competition_id"]').val();
    if (value == "") {
        $('#create-competition').show();
        $('[id*="group_id"]').parent().hide();
        $('[id*="group_name"]').parent().show();

    } else {
        $('#create-competition').hide();
        $('[id*="group_id"]').parent().show();
        $('[id*="group_name"]').parent().hide();
    }
}
window.group_visibility = function() {
    var value = $('[id*="_group_id"]').val();
    if (value == "") {
        $('[id*="group_id"]').parent().hide();
        $('[id*="group_name"]').parent().show();
    } else {
        $('[id*="group_id"]').parent().show();
        $('[id*="group_name"]').parent().hide();
    }
}

window.result_visibility = function() {
    var value = $('#runner_category_id').val();
    (value == "10") ? $('#create-result').hide(): $('#create-result').show()
}
