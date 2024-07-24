alias Ecto.UUID
alias Livre.Repo
alias Livre.Repo.User

now =
  DateTime.utc_now()
  |> DateTime.truncate(:second)

[
  {"George Weasley",
   "https://static.wikia.nocookie.net/harrypotter/images/8/8f/PromoHP7_George_Weasley.jpg/revision/latest?cb=20110901202407&path-prefix=fr"},
  {"Harry Potter",
   "https://resize.elle.fr/square_1280/var/plain_site/storage/images/loisirs/livres/news/harry-potter-de-nouveaux-secrets-devoiles-2913738/53231812-1-fre-FR/Harry-Potter-de-nouveaux-secrets-devoiles.jpg"},
  {"Ron Weasley",
   "https://images.ctfassets.net/usf1vwtuqyxm/1u3RmbxLrGMysu0Smacesu/43b7405e95859ba08ea646dc16fa722e/WB_F3_Scabbers_RonClutchesScabbersOnGround_C608-13_UP_HPE3.jpg?fm=jpg&q=70&w=2560"},
  {"Hermione Granger",
   "https://static.wikia.nocookie.net/harrypotter/images/9/9f/Hermione_with_her_Hand_Up.jpg/revision/latest/scale-to-width-down/266?cb=20080515230612"},
  {"Neville Longdubat",
   "https://pm1.aminoapps.com/6916/9a884bd21734cf453f6079de3d4dace88166de88r1-640-400v2_00.jpg"},
  {"Voldemort",
   "https://static.wikia.nocookie.net/antagonists/images/5/5f/Screenshot_2023-08-16_7.06.20_PM.png/revision/latest?cb=20230816230709"},
  {"Hadrig",
   "https://preview.redd.it/the-one-and-only-ps1-hagrid-v0-tiqgkvkcqidb1.jpg?width=640&crop=smart&auto=webp&s=68635fe0b703dac8760b8aa445a99ed0486fc709"}
]
|> Enum.map(fn {name, pic} ->
  %{
    id: UUID.generate(),
    email: String.replace(name, " ", "_") <> "@test.com",
    name: name,
    picture_url: pic,
    inserted_at: now,
    updated_at: now
  }
end)
|> tap(&Repo.insert_all(User, &1))
