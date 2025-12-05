module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2018, // Jika ingin menggunakan fitur ES2018
  },
  extends: [
    "eslint:recommended",
    "google", // Pastikan "google" ada di sini setelah Anda menginstal eslint-config-google
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "max-len": ["error", {"code": 100}], // Mengatur panjang baris menjadi 100 karakter
  },
  overrides: [
    {
      files: ["**/*.spec.*"], // Menambahkan pengaturan untuk file spesifik seperti tes
      env: {
        mocha: true, // Jika Anda menggunakan mocha untuk testing
      },
      rules: {},
    },
  ],
  globals: {},
};
