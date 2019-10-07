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

function sortTable(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("example");
  switching = true;
  // Set the sorting direction to ascending:
  dir = "asc";
  /* Make a loop that will continue until
  no switching has been done: */
  while (switching) {
    // Start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /* Loop through all table rows (except the
    first, which contains table headers): */
    for (i = 1; i < (rows.length - 1); i++) {
      // Start by saying there should be no switching:
      shouldSwitch = false;
      /* Get the two elements you want to compare,
      one from current row and one from the next: */
      x = rows[i].querySelectorAll('td')[n];
      y = rows[i + 1].querySelectorAll('td')[n];
      /* Check if the two rows should switch place,
      based on the direction, asc or desc: */
      if ([3, 4, 5].includes(n)) {
        var textX = x.innerText.replace(/\D/g,'');
        var textY = y.innerText.replace(/\D/g,'');
        textX = parseInt(textX, 10)
        textY = parseInt(textY, 10)
        console.log(textX, textY)
        if ((dir == "asc") && (textX < textY)) {
          shouldSwitch = true;
          break
        } else if ((dir == "desc") && (textX > textY)) {
          shouldSwitch = true;
          break
        }
      } else if (dir == "asc") {
        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
          // If so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      } else if (dir == "desc") {
        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
          // If so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      }
    }


    if (shouldSwitch) {
      /* If a switch has been marked, make the switch
      and mark that a switch has been done: */
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      // Each time a switch is done, increase this count by 1:
      switchcount += 1;
    } else {
      /* If no switching has been done AND the direction is "asc",
      set the direction to "desc" and run the while loop again. */
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}

const headers = document.querySelectorAll(".sortable")
headers.forEach(header => {
  header.addEventListener("click", event => {
    event.preventDefault()
    const n = parseInt(event.currentTarget.dataset.id, 10)
    sortTable(n)
  })
})

