import flatpickr from "flatpickr";
import "flatpickr/dist/themes/dark.css";

const initFlatpickr = () => {
  const input = document.querySelector(".date-field");
  if (input) {
    flatpickr(input, {
      minDate: "today",
      maxDate: new Date().fp_incr(365)
    });
  }
}

export { initFlatpickr }
