const express = require('express');
const app = express();
const port = 3000;

// Mock firmware database
const firmwareDatabase = [
  {
    device_model: "1234",
    hardware_revision: "A1",
    manufacturer_name: "ExampleCorp",
    version: "1.2.0",
    release_notes: "This update includes bug fixes and performance improvements.",
    file_url: "https://asset.cloudinary.com/dw30tfofi/d402e6dcee6630aa348083529abcfa6a",
    release_date: "2024-01-15"
  }
];

app.get('/v2/firmware/latest', (req, res) => {
  const { device_model, firmware_revision, hardware_revision, manufacturer_name } = req.query;

  if (!device_model || !firmware_revision || !hardware_revision || !manufacturer_name) {
    return res.status(400).json({ error: "Invalid request. Missing or incorrect parameters." });
  }

  const firmware = firmwareDatabase.find(fw =>
    fw.device_model === device_model &&
    fw.hardware_revision === hardware_revision &&
    fw.manufacturer_name === manufacturer_name
  );

  if (!firmware) {
    return res.status(404).json({ error: "No firmware update available for the specified device." });
  }

  return res.status(200).json(firmware);
});

app.listen(port, () => {
  console.log(`Firmware server running at http://localhost:${port}`);
});
