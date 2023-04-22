categories = [
  {
    "id": 1,
    "category_name": 'MISRM',
    "full_name": 'Maestru Internaţional al Sportului',
    "points": 300.0
  },
  {
    "id": 2,
    "category_name": 'MSRM',
    "full_name": 'Maestru al Sportului',
    "points": 100.0
  },
  {
    "id": 3,
    "category_name": 'CMSRM',
    "full_name": 'Candidat în Maeștri ai Sportului',
    "points": 30.0
  },
  {
    "id": 4,
    "category_name": 'I',
    "full_name": 'Categoria I',
    "points": 10.0
  },
  {
    "id": 5,
    "category_name": 'II',
    "full_name": 'Categoria II',
    "points": 4.0
  },
  {
    "id": 6,
    "category_name": 'III',
    "full_name": 'Categoria III',
    "points": 2.0
  },
  {
    "id": 7,
    "category_name": 'I j',
    "full_name": 'Categoria I juniori',
    "points": 1.0
  },
  {
    "id": 8,
    "category_name": 'II j',
    "full_name": 'Categoria II juniori',
    "points": 0.5
  },
  {
    "id": 9,
    "category_name": 'III j',
    "full_name": 'Categoria III juniori',
    "points": 0.3
  },
  {
    "id": 10,
    "category_name": 'f/c',
    "full_name": 'Fara Categorie',
    "points": 0.0
  }
]

categories.each do |category|
  Category.create(category)
end

Competition.create("id": 0, "competition_name": 'Fara Competitie', "date": '2021-08-01')
Competition.create("id": 1, "competition_name": 'Diminuare Categorie', "date": '2021-08-01')
Club.create("id": 0, "club_name": 'Individual')
Group.create("id": 0, "group_name": 'No Group', "competition_id": 0)
Group.create("id": 1, "group_name": 'Diminuare Categorie', "competition_id": 1)
User.create!(email: "test@mail.ru", password: "1234qwe1234", admin: true)
