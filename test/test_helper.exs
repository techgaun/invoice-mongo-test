ExUnit.start()
Faker.start()

Invoice.Repo.delete_all(Invoice.Invoices.Invoice)
