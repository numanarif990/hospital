/**
 * Hospital Management System — OPD Consultation Slip Printing
 *
 * Exact JavaScript port of the Flutter/Dart application.
 * Designed for 80mm thermal receipt printers (e.g. Black Copper BC-85AC).
 *
 * Features:
 *  - Password gate (password: 2004)
 *  - Patient form with validation
 *  - Auto-capitalize first letter of text inputs
 *  - Persistent fields via localStorage (reg, session, consultation, token)
 *  - Print OPD slip optimized for 80mm thermal paper
 *  - After printing: reg += 3, consult += 2, token += 1, session unchanged
 *  - Reset default printer (clears localStorage printer key)
 */

(function () {
  'use strict';

  // ========== DOM References ==========
  const passwordScreen = document.getElementById('passwordScreen');
  const mainScreen = document.getElementById('mainScreen');
  const passwordForm = document.getElementById('passwordForm');
  const passwordInput = document.getElementById('passwordInput');
  const togglePasswordBtn = document.getElementById('togglePasswordBtn');
  const passwordError = document.getElementById('passwordError');
  const patientForm = document.getElementById('patientForm');
  const printBtn = document.getElementById('printBtn');
  const printBtnText = document.getElementById('printBtnText');
  const resetPrinterBtn = document.getElementById('resetPrinterBtn');
  const snackbarEl = document.getElementById('snackbar');
  const printSlip = document.getElementById('printSlip');

  // Form fields
  const fields = {
    patientName: document.getElementById('patientName'),
    soField: document.getElementById('soField'),
    ageField: document.getElementById('ageField'),
    genderField: document.getElementById('genderField'),
    regNumber: document.getElementById('regNumber'),
    sessionNumber: document.getElementById('sessionNumber'),
    consultationNumber: document.getElementById('consultationNumber'),
    tokenNumber: document.getElementById('tokenNumber'),
    doctorName: document.getElementById('doctorName'),
  };

  // Required fields and their error containers
  const requiredFields = [
    { el: fields.patientName, errId: 'patientNameError', label: 'Patient Name' },
    { el: fields.ageField, errId: 'ageFieldError', label: 'Age' },
    { el: fields.genderField, errId: 'genderFieldError', label: 'Gender' },
    { el: fields.regNumber, errId: 'regNumberError', label: 'Registration Number (Reg #)' },
    { el: fields.sessionNumber, errId: 'sessionNumberError', label: 'Session #' },
    { el: fields.consultationNumber, errId: 'consultationNumberError', label: 'Consultation Number (Con #)' },
    { el: fields.tokenNumber, errId: 'tokenNumberError', label: 'Token Number' },
    { el: fields.doctorName, errId: 'doctorNameError', label: 'Doctor Name' },
  ];

  let isLoading = false;

  // ========== Snackbar ==========
  let snackbarTimeout = null;
  function showSnackbar(message, type) {
    if (snackbarTimeout) clearTimeout(snackbarTimeout);
    snackbarEl.textContent = message;
    snackbarEl.className = 'snackbar ' + type;
    // Force reflow
    void snackbarEl.offsetWidth;
    snackbarEl.classList.add('show');
    snackbarTimeout = setTimeout(() => {
      snackbarEl.classList.remove('show');
    }, 3500);
  }

  // ========== LocalStorage Helpers (mirror SharedPreferences) ==========
  function saveField(key, value) {
    try {
      localStorage.setItem(key, value);
    } catch (e) {
      // Silently fail
    }
  }

  function loadField(key, defaultValue) {
    try {
      const v = localStorage.getItem(key);
      return v !== null ? v : defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  function removeField(key) {
    try {
      localStorage.removeItem(key);
    } catch (e) {
      // Silently fail
    }
  }

  // ========== Capitalize First Letter Formatter ==========
  function capitalizeFirstLetter(input) {
    input.addEventListener('input', function () {
      const val = this.value;
      if (val.length > 0) {
        this.value = val.charAt(0).toUpperCase() + val.slice(1);
      }
    });
  }

  // Apply to all text inputs (not number or select)
  capitalizeFirstLetter(fields.patientName);
  capitalizeFirstLetter(fields.soField);
  capitalizeFirstLetter(fields.doctorName);

  // ========== Tab Order (mirroring Flutter's onFieldSubmitted focus chain) ==========
  const tabOrder = [
    fields.patientName,
    fields.soField,
    fields.ageField,
    fields.regNumber,
    fields.sessionNumber,
    fields.consultationNumber,
    fields.tokenNumber,
    fields.doctorName,
  ];

  tabOrder.forEach((field, i) => {
    field.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        if (i < tabOrder.length - 1) {
          tabOrder[i + 1].focus();
        } else {
          field.blur();
        }
      }
    });
  });

  // ========== Save Tracked Fields on Change ==========
  fields.regNumber.addEventListener('input', () => saveField('reg_number', fields.regNumber.value));
  fields.sessionNumber.addEventListener('input', () => saveField('session_number', fields.sessionNumber.value));
  fields.consultationNumber.addEventListener('input', () => saveField('consultation_number', fields.consultationNumber.value));
  fields.tokenNumber.addEventListener('input', () => saveField('token_number', fields.tokenNumber.value));

  // ========== Load Saved Fields ==========
  function loadSavedFields() {
    fields.regNumber.value = loadField('reg_number', '3570');
    fields.sessionNumber.value = loadField('session_number', '45');
    fields.consultationNumber.value = loadField('consultation_number', '3456');
    fields.tokenNumber.value = loadField('token_number', '5');
    fields.doctorName.value = 'Gen. Physician-MFH';
    fields.patientName.value = 'usman';
    fields.ageField.value = '45';
    fields.genderField.value = 'Male';
  }

  // ========== Password Screen Logic ==========
  let passwordObscured = true;

  togglePasswordBtn.addEventListener('click', () => {
    passwordObscured = !passwordObscured;
    passwordInput.type = passwordObscured ? 'password' : 'text';
    togglePasswordBtn.textContent = passwordObscured ? '👁️' : '🙈';
  });

  passwordForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const val = passwordInput.value.trim();

    if (!val) {
      passwordError.textContent = 'Please enter password';
      return;
    }

    if (val === '2004') {
      // Success — show main screen
      passwordScreen.style.display = 'none';
      mainScreen.classList.add('active');
      loadSavedFields();
    } else {
      passwordError.textContent = 'Incorrect password';
    }
  });

  // Clear error when typing
  passwordInput.addEventListener('input', () => {
    passwordError.textContent = '';
  });

  // Submit on Enter
  passwordInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      passwordForm.dispatchEvent(new Event('submit'));
    }
  });

  // ========== Form Validation ==========
  function validateForm() {
    let valid = true;

    requiredFields.forEach((f) => {
      const errEl = document.getElementById(f.errId);
      const val = f.el.value.trim();
      if (!val) {
        errEl.textContent = f.label + ' is required';
        valid = false;
      } else {
        errEl.textContent = '';
      }
    });

    return valid;
  }

  // Clear individual errors on input
  requiredFields.forEach((f) => {
    f.el.addEventListener('input', () => {
      const errEl = document.getElementById(f.errId);
      if (f.el.value.trim()) {
        errEl.textContent = '';
      }
    });
  });

  // ========== Date Formatting (dd-MM-yyyy HH:mm) ==========
  function formatDate(date) {
    const dd = String(date.getDate()).padStart(2, '0');
    const mm = String(date.getMonth() + 1).padStart(2, '0');
    const yyyy = date.getFullYear();
    const hh = String(date.getHours()).padStart(2, '0');
    const min = String(date.getMinutes()).padStart(2, '0');
    return dd + '-' + mm + '-' + yyyy + ' ' + hh + ':' + min;
  }

  // ========== Generate Print Slip HTML ==========
  function generateSlipHTML() {
    const now = new Date();
    const dateStr = formatDate(now);
    const patientName = fields.patientName.value.trim();
    const so = fields.soField.value.trim() || '-';
    const age = fields.ageField.value.trim();
    const gender = fields.genderField.value;
    const regNum = fields.regNumber.value.trim();
    const sessionNum = fields.sessionNumber.value.trim();
    const conNum = fields.consultationNumber.value.trim();
    const tokenNum = fields.tokenNumber.value.trim();
    const doctorName = fields.doctorName.value.trim();

    return `
      <div class="slip-header">
        <div class="hospital-name">Mirza Abdul Qayyum Memorial Hospital</div>
        <div class="hospital-name-underline"></div>
      </div>

      <div class="slip-header">
        <div class="address">213-C, Sec. C/3 Allama Iqbal Road Mirpur A.K</div>
        <div class="phone">Phone: 05827-444 050</div>
      </div>

      <div class="slip-opd-title">
        <div class="opd-text">OPD. CONSULTATION SLIP</div>
        <div class="opd-underline"></div>
      </div>

      <div class="slip-token-row">
        <span class="token-label">Token No:</span>
        <div class="token-circle">${tokenNum}</div>
      </div>

      <div class="slip-doctor-section">
        <div class="physician-name">Physician: ${doctorName}</div>
        <div class="physician-underline"></div>
        <div class="physician-role">General Physician</div>
      </div>

      <div class="slip-patient-info">
        <div class="slip-left-col">
          <div class="slip-info-row">
            <div class="info-text">Date: ${dateStr}</div>
            <div class="info-line"></div>
          </div>
          <div class="slip-info-row">
            <div class="info-text">Patient: ${patientName}</div>
            <div class="info-line"></div>
          </div>
          <div class="slip-info-row">
            <div class="info-text">S/o: ${so}</div>
            <div class="info-line"></div>
          </div>
          <div class="slip-info-row">
            <div class="info-text">Age: ${age}Y / ${gender}</div>
            <div class="info-line"></div>
          </div>
        </div>

        <div class="slip-right-col">
          <div class="slip-info-row-flex">
            <div>
              <div style="display:flex;justify-content:space-between;">
                <span class="info-label">Reg. #:</span>
                <span class="info-value">${regNum}</span>
              </div>
              <div class="info-line"></div>
            </div>
          </div>
          <div class="slip-info-row-flex">
            <div>
              <div style="display:flex;justify-content:space-between;">
                <span class="info-label">Session#:</span>
                <span class="info-value">${sessionNum}</span>
              </div>
              <div class="info-line"></div>
            </div>
          </div>
          <div class="slip-info-row-flex">
            <div>
              <div style="display:flex;justify-content:space-between;">
                <span class="info-label">Con. #:</span>
                <span class="info-value">${conNum}</span>
              </div>
              <div class="info-line"></div>
            </div>
          </div>
        </div>
      </div>

      <div class="slip-separator"></div>

      <div class="slip-total-section">
        <div class="total-line"></div>
        <div class="total-text">Total Rs: 500</div>
        <div class="total-line"></div>
      </div>

      <div class="slip-operator">Operator: Usman Arif</div>
      <div class="slip-bottom-separator"></div>
      <div class="slip-powered-by">Powered by: www.goldensoftpk.com</div>
    `;
  }

  // ========== Print OPD Slip ==========
  function printOPDSlip() {
    if (!validateForm()) return;
    if (isLoading) return;

    isLoading = true;
    printBtn.disabled = true;
    printBtnText.textContent = 'Printing...';
    // Replace icon with spinner
    const iconSpan = printBtn.querySelector('.print-icon');
    if (iconSpan) {
      iconSpan.outerHTML = '<span class="spinner"></span>';
    }

    // Save tracked fields before printing
    saveField('reg_number', fields.regNumber.value);
    saveField('session_number', fields.sessionNumber.value);
    saveField('consultation_number', fields.consultationNumber.value);
    saveField('token_number', fields.tokenNumber.value);

    // Generate slip HTML
    printSlip.innerHTML = generateSlipHTML();

    // Small delay to let DOM render, then print
    setTimeout(() => {
      window.print();

      // After print dialog closes, increment fields
      // (Web: we assume print succeeded, matching Flutter's kIsWeb behavior)
      incrementFieldsAfterPrint();

      // Reset button state
      isLoading = false;
      printBtn.disabled = false;
      printBtnText.textContent = 'Print';
      const spinner = printBtn.querySelector('.spinner');
      if (spinner) {
        spinner.outerHTML = '<span class="print-icon">🖨️</span>';
      }

      showSnackbar('OPD slip sent to printer!', 'success');
    }, 300);
  }

  // ========== Increment Fields After Successful Print ==========
  function incrementFieldsAfterPrint() {
    let reg = parseInt(fields.regNumber.value, 10) || 0;
    let session = parseInt(fields.sessionNumber.value, 10) || 0;
    let consult = parseInt(fields.consultationNumber.value, 10) || 0;
    let token = parseInt(fields.tokenNumber.value, 10) || 0;

    reg += 3;
    // session stays the same (matches Flutter: session = session)
    consult += 2;
    token += 1;

    fields.regNumber.value = reg.toString();
    fields.sessionNumber.value = session.toString();
    fields.consultationNumber.value = consult.toString();
    fields.tokenNumber.value = token.toString();

    saveField('reg_number', reg.toString());
    saveField('session_number', session.toString());
    saveField('consultation_number', consult.toString());
    saveField('token_number', token.toString());
  }

  // ========== Reset Default Printer ==========
  function resetDefaultPrinter() {
    removeField('default_printer');
    showSnackbar(
      'Default printer reset. You will be asked to select a printer on next print.',
      'warning'
    );
  }

  // ========== Event Bindings ==========
  printBtn.addEventListener('click', printOPDSlip);
  resetPrinterBtn.addEventListener('click', resetDefaultPrinter);

  // ========== Focus password input on load ==========
  passwordInput.focus();
})();
