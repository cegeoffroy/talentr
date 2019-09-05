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

function download_csv(csv, filename) {
    var csvFile;
    var downloadLink;

    // CSV FILE
    csvFile = new Blob([csv], {type: "text/csv"});

    // Download link
    downloadLink = document.createElement("a");

    // File name
    downloadLink.download = filename;

    // We have to create a link to the file
    downloadLink.href = window.URL.createObjectURL(csvFile);

    // Make sure that the link is not displayed
    downloadLink.style.display = "none";

    // Add the link to your DOM
    document.body.appendChild(downloadLink);

    // Lanzamos
    downloadLink.click();
}

function export_table_to_csv(html, filename) {
  var csv = [];
  var rows = document.querySelectorAll("#example tr");

    for (var i = 0; i < rows.length; i++) {
    var row = [], cols = rows[i].querySelectorAll("td, th");

        for (var j = 0; j < cols.length; j++)
            row.push(cols[j].innerText);

    csv.push(row.join(","));
  }

    // Download CSV
    download_csv(csv.join("\n"), filename);
}

if (document.querySelector(".csv-button")) {
  document.querySelector(".csv-button").addEventListener("click", function () {
      var html = document.querySelector("#example").outerHTML;
    export_table_to_csv(html, "table.csv");
  });
}

