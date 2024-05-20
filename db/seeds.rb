# frozen_string_literal: true

User.create(email: 'example@example.com', password: 'exampass1234')

Car.create(
  [
    { model: 'Example model', license_number: '123EXMPL' },
    { model: 'Another model', license_number: '456EXMPL' },
    { model: 'Test model',    license_number: '789EXMPL' }
  ]
)
