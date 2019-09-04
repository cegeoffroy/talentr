import "bootstrap";
import { initFlatpickr } from '../plugins/init_flatpicker';

initFlatpickr();

$(document).ready(function() {
      $('#example tr').click(function(e) {

         if ($(e.target).hasClass('fas')) {
            console.log('hello');
          } else {
          var href = $(this).find("a").attr("href");
          if(href) {
              window.location = href;
          }
          };

      });
    });
