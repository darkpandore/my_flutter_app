  class Brand {
  static const List<String> brands = [
  "Gucci", "Prada", "Versace", "Dior", "Balenciaga", "Louis Vuitton", "Hermès", "Chanel", "Burberry", 
  "Fendi", "Givenchy", "Valentino", "Moncler", "Off-White", "Saint Laurent", "Alexander McQueen", 
  "Maison Margiela", "Jacquemus", "Celine", "Goyard", "Berluti", "Ermenegildo Zegna", "Loro Piana", 
  "Bottega Veneta", "Etro", "Brunello Cucinelli", "Dries Van Noten", "Acne Studios", "Isabel Marant", 
  "Rick Owens", "Loewe", "Proenza Schouler", "Tory Burch", "Chloé", "Balmain", "Miu Miu", "Kenzo", 
  "Moschino", "Thom Browne", "Lanvin", "Rochas", "Courrèges", "Jean Paul Gaultier", "Delvaux",
  // Casual chic, preppy, et sportswear américain
  "Brooks Brothers", "J.Crew Factory", "Vineyard Vines", "Southern Tide", "Gant Rugger",
  "Hackett London", "Banana Republic Heritage", "Club Room", "Eddie Bauer", "LL Bean Signature",
  "Peter Millar", "Lands' End", "Orvis", "Izod", "Arrow USA", "George", "Calvin Klein Sportswear","Calvin Klein",
  "Perry Ellis", "Bugatchi", "John Varvatos",

  // Nautique et bord de mer
  "Barbour Beacon", "Henri Lloyd", "Sperry", "Sebago", "Tommy Bahama", "Southern Proper",
  "Cape Cod USA", "Kuhl", "Peter Hahn", "Scotch & Soda Yacht Club",

  // Style vintage américain
  "Pendleton Woolen Mills", "Wrangler Retro", "Lee Vintage", "Champion USA Vintage",
  "Faherty", "Filson Seattle", "Todd Snyder", "Golden Bear", "Taylor Stitch", "Buck Mason","Champion","USA",

  // Outdoor classique et élégant
  "Timberland Heritage", "Patagonia Legacy Collection", "REI Co-op Classics",
  "Cabela's Signature Series", "Belstaff Outdoor",


  // Streetwear
  "Supreme", "Stüssy", "Palace", "Bape", "Fear of God", "Essentials", "Carhartt WIP", "Kith", "Noah", 
  "The Hundreds", "10.Deep", "A Bathing Ape", "Undefeated", "Obey", "HUF", "Diamond Supply Co.", "Ripndip", 
  "Primitive", "Billionaire Boys Club", "Aime Leon Dore", "Anti Social Social Club", "Rhude", "Famous Stars & Straps", 
  "Off the Hook", "Rokit", "Saturdays NYC", "Heron Preston", "Neighborhood", "WTAPS", "Mastermind Japan",

  // Sport & Outdoor
  "Nike", "Adidas", "Reebok", "New Balance", "Under Armour", "Puma", "Asics", "Saucony", "Fila", "Columbia",
  "Hoka One One", "Brooks", "On Running", "The North Face", "Columbia Sportswear", "Arc'teryx", 
  "Patagonia", "Salomon", "Mammut", "Canada Goose", "Helly Hansen", "Rab", "Outdoor Research", 
  "Mountain Hardwear", "Black Diamond", "Berghaus", "Lafuma", "Fjällräven", "Jack Wolfskin", "Karrimor", 
  "Napapijri", "Moncler Grenoble", "Rossignol", "Atomic", "K2 Sports", "Burton", "Volcom", "O'Neill",

  // Chaussures
  "Converse", "Vans", "Timberland", "Dr. Martens", "Clarks", "Skechers", "Crocs", "Birkenstock", 
  "Teva", "Keen", "Merrell", "Salewa", "Altra", "Etnies", "DC Shoes", "Globe", "Emerica", "Supra", 
  "Heschung", "Paraboot", "Santoni", "Alden", "Church's", "John Lobb", "Tricker's", "Red Wing", "Lee","Lee Cooper",
  "Wolverine", "Blundstone", "R.M. Williams",

  // Casual & Mode rapide
  "Zara", "H&M", "Uniqlo", "Primark", "Gap", "Old Navy", "Banana Republic", "American Eagle", 
  "Hollister", "Abercrombie & Fitch", "Aéropostale", "Forever 21", "Urban Outfitters", "Topshop", 
  "Boohoo", "Shein", "PrettyLittleThing", "Missguided", "Fashion Nova", "Mango", "Massimo Dutti", 'Stone island',
  "Stradivarius", "Bershka", "Pull & Bear",

  // Haute Couture
  "Christian Dior", "Chanel", "Valentino Haute Couture", "Jean Paul Gaultier Haute Couture", 
  "Schiaparelli", "Elie Saab", "Giambattista Valli", "Zuhair Murad", "Iris Van Herpen", 
  "Ralph & Russo", "Tony Ward", "Azzaro Couture", "Dolce & Gabbana Alta Moda",

  // Joaillerie & montres
  "Cartier", "Tiffany & Co.", "Van Cleef & Arpels", "Harry Winston", "Chopard", "Piaget", "Bvlgari", 
  "Rolex", "Patek Philippe", "Audemars Piguet", "Vacheron Constantin", "Jaeger-LeCoultre", 
  "Omega", "Breitling", "TAG Heuer", "IWC Schaffhausen", "Panerai", "Hublot", "Richard Mille",

  // Cosmétiques & parfumerie
  "L'Oréal", "Maybelline", "Lancôme", "Chanel Beauté", "Dior Beauté", "Fenty Beauty", "Huda Beauty", 
  "NARS", "MAC Cosmetics", "Benefit", "Urban Decay", "Sephora", "Estée Lauder", "Clinique", 
  "Bobbi Brown", "Too Faced", "Yves Saint Laurent Beauté", "Tom Ford Beauty", "Charlotte Tilbury", 
  "Guerlain", "Shiseido", "Amorepacific",

  // Accessoires & maroquinerie
  "Louis Vuitton", "Hermès", "Gucci", "Goyard", "Longchamp", "Coach", "Michael Kors", "Kate Spade", 
  "Tory Burch", "Marc Jacobs", "Fossil", "Dooney & Bourke", "Coccinelle", "Furla", "Prada", "MCM", 
  "Lancel", "Sandro", "Maje",

  // Lunetterie
  "Ray-Ban", "Oakley", "Persol", "Maui Jim", "Oliver Peoples", "Mykita", "Jacques Marie Mage", 
  "Cartier Eyewear", "Chanel Eyewear", "Dior Homme Lunettes", "Gentle Monster", "Vuarnet", 
  "Etnia Barcelona",

  // Montres connectées & bracelets
  "Apple", "Samsung", "Garmin", "Fitbit", "Xiaomi", "Polar", "Withings", "Suunto", "Huawei", 
  "Tag Heuer Connected",

  // Vêtements techniques & utilitaires
  "Dickies", "Carhartt", "Levi's", "Wrangler", "Red Kap", "Danner", "5.11 Tactical", 
  "Propper", "Timberland Pro", "Helikon-Tex", "Barbour", "Schott NYC", "Alpha Industries", "Lacoste","Lacoste Live",
  "Filson", "Pendleton", "Belstaff", "Woolrich", "Orvis",

  // Vêtements pour enfants
  "Petit Bateau", "Okaïdi", "Jacadi", "Tartine et Chocolat", "Catimini", "Bonpoint", "DPAM", 
  "Kidiliz", "Sergent Major", "Cyrillus",

  // Divers
  "Fred Perry", "Paul Smith", "Ted Baker", "J.Crew", "Bonobos", "Rag & Bone", "Theory", 
  "Vince", "Club Monaco", "Rhone", "Everlane", "Sezane", "Rouje", "Reformation", "A.P.C.", 
  "Armor Lux", "Petit Bateau", "Muji", "COS", "Rains", "Hunter", "Barbour International",
  
  "Isotoner", "Sorel", "Heschung", "Saint James", "Fusalp", "Pyrenex", "Penfield", "Eider",
  "Kappa", "Umbro", "Ellesse", "Diadora", "Joma", "Lotto", "Mizuno", "Jack & Jones", "Aigle","Harley Davidson", "L.L Bean","Helly Hansen","arc'teryx","Papy (Vintage Dressing)",  "Le Coq Sportif",
    "Agnès B.", "Ba&sh", "Sessùn", "Comptoir des Cotonniers", "IKKS", "Desigual", "Esprit", 
  "Morgan", "Cache Cache", "Camaïeu", "Sandro Homme", "Gant", "Etam", "La Redoute", "Monoprix",
  "Celio", "Devred 1902", "Brice", "Zapa", "Claudie Pierlot", "Bizzbee", "Pimkie", "Jennyfer","Caroll",

  // Streetwear & Urban chic
  "Kaporal", "Superdry", "Volcom", "DC Shoes", "Quiksilver", "Roxy", "Billabong", "Element",
  "Santa Cruz", "Obey", "Independent", "Thrasher", "Vans Vault", "Gramicci", "Carrots by Anwar", 
  "Patta", "Pleasures", "Aries", "Daily Paper", "Brain Dead", "HLZBLZ", "Southpole", "Ecko Unltd.",

  // Marques européennes
  "Scotch & Soda", "Maison Scotch", "Denham", "G-Star", "Pepe Jeans London", "Diesel Black Gold", 
  "Replay", "Lonsdale", "Ben Sherman", "Farah", "Baracuta", "Reiss", "Jack Wills", "Topman",
  "Next", "Primigi", "Luisa Spagnoli", "Max Mara", "Sportmax", "Patrizia Pepe", "Twinset",
  
  // Outdoor et Randonnée
  "La Sportiva", "Millet", "Norrona", "Ortovox", "Ternua", "Vaude", "Deuter", "Osprey", 
  "Gregory", "Klymit", "Marmot", "Craghoppers", "Sherpa Adventure Gear", "Haglöfs", 
  "Icebreaker", "Smartwool", "Terramar", "Seirus", "Montane",

  // Luxe émergent
  "The Row", "Gabriela Hearst", "Totême", "Self-Portrait", "Khaite", "Nanushka", "Cult Gaia", 
  "Staud", "Rosie Assoulin", "Jonathan Simkhai", "Altuzarra", "Zimmermann", "Alaïa", 
  "Balenciaga Homme", "Peter Do", "Marine Serre", "Maison Rabih Kayrouz", "Pyer Moss", "Luar",

  // Chaussures contemporaines
  "Veja", "Common Projects", "Golden Goose", "Axel Arigato", "Clae", "Maison Mihara Yasuhiro", 
  "Greats", "Koio", "New Republic", "Sebago", "Grenson", "Tods", "Magnanni", "Carmina", 
  "Meermin", "Paul Parkman", "Allbirds", "Giesswein", "Nike ACG", "Karhu",

  // Prêt-à-porter féminin
  "Anthropologie", "Free People", "Reformation", "Rouje", "Diane Von Fürstenberg", "Cinq à Sept", 
  "Rebecca Minkoff", "Alice + Olivia", "Erdem", "Needle & Thread", "Selfridges", "Sandro Femme", 
  "Maje Femme", "Claudie Pierlot Femme", "Séraphine", "Madewell", "Mother Denim", "DL1961", "AG Jeans",

  // Sport & Performance
  "Kjus", "Bogner", "X-Bionic", "Descente", "Spyder", "Castore", "Ortlieb", "Gore Wear", 
  "Falke", "Compressport", "2XU", "Craft", "Xero Shoes", "Topo Athletic", "Newton Running", 
  "Brooks England", "Assos", "Castelli", "Pearl Izumi", "Le Col",

  // Denim & Jeans
  "Edwin", "AG Adriano Goldschmied", "Hudson Jeans", "True Religion", "Lucky Brand", "Nudie Jeans", 
  "Joe's Jeans", "7 For All Mankind", "Wrangler Pro", "Diesel Red Tag", 
  "A.P.C. Denim", "Acne Studios Denim", "Jeanerica", "Balmain Jeans","McGregor","Stussy","Nautica",

  // Haute Joaillerie & Accessoires
  "Pomellato", "David Yurman", "Boucheron", "Chaumet", "Buccellati", "Graff Diamonds", "Dinh Van", 
  "Tasaki", "Mikimoto", "Korloff", "De Beers", "Messika", "Djula", "Repossi", "Fred Joaillier", 
  "Baume & Mercier", "Ressence", "Nomos Glashütte", "Seiko", "Citizen", "Casio G-Shock", 
  "Luminox", "Tissot", "Longines", "Hamilton", "Ball Watch","Ralph Lauren", "Lauren Ralph Lauren", "Polo Ralph Lauren",

  // Mode rapide asiatique
  "Miniso", "Giordano", "Uniqlo U", "MUJI Apparel", "HLA", "SHEIN Premium", "Spao", "Stylenanda", 
  "E-Land", "Gong Cha Apparel", "Jins", "WEGO Japan", "ABC Mart", "Beams Japan", "United Arrows", 
  "Tomorrowland", "Tsumori Chisato", "Earth Music & Ecology",

  // Prêt-à-porter enfants
  "Petit Lem", "Baby Dior", "Bonpoint", "Moncler Enfant", "Kenzo Kids", "Chloé Kids", 
  "Ralph Lauren Kids", "Nike Kids", "Adidas Originals Kids", "Tartine et Chocolat Baby", 
  "Jacadi Baby", "OshKosh B'gosh", "Carter's", "Little Marc Jacobs", "Gap Kids",

  // Uniformes & travail
  "Red Kap", "Blaklader", "Carhartt Pro", "Dickies Medical", "Caterpillar Apparel", "Snickers Workwear", 
  "Bulwark", "Wrangler Riggs", "Chef Works", "5.11 Tactical Pro", "Blundstone Pro", "Hi-Tec", 
  "Darn Tough", "LaCrosse Footwear", "Rocky Boots",

  // Maroquinerie de créateur
  "Moynat", "Sophie Hulme", "Mulberry", "Anya Hindmarch", "Strathberry", "Wandler", "Boyy", 
  "The Row Handbags", "Brunello Cucinelli Bags", "Gabriela Hearst Nina", "Mark Cross", "Telfar","Tommy Hilfiger", "Chaps by Ralph Lauren",
  "JW Pei", "Mansur Gavriel", "Polène", "Senreve",

  // Autres accessoires & designers émergents
  "Mejuri", "Ana Luisa", "Missoma", "Finlay & Co.", "Warby Parker", "Sunday Somewhere", "Chimi Eyewear", 
  "Komono", "Le Specs", "Retrosuperfuture", "Gentle Fawn", "Yuzefi", "By Far", "Simon Miller", 
  "Cult Gaia", "Nanushka Bags", "Rains Accessories", "Hunter Boots", "Sorel Footwear", 
  "Aigle Paris", "Heschung Chaussures",

  // Cosmétiques et lifestyle
  "Glossier", "The Ordinary", "Drunk Elephant", "Summer Fridays", "La Mer", "Jo Malone", 
  "Maison Margiela Fragrances", "Byredo", "Diptyque", "Aesop", "Lush", "Sol de Janeiro", 
  "Kiehl's", "Clarins", "Biotherm", "Fresh", "Laneige", "Innisfree", "Sulwhasoo", "COSRX",
    "Jean Patou", "Balmain Homme", "Akris", "Delpozo", "Hermès Homme", "Paule Ka", "Victoria Beckham", 
  "Roland Mouret", "Sonia Rykiel", "Temperley London", "Elie Tahari", "Badgley Mischka", "Marchesa",
  "Zac Posen", "Philipp Plein", "Lagerfeld", "Erika Cavallini", "Costarellos", "Fabiana Filippi",
  
  // Streetwear et lifestyle
  "Fear of God Essentials", "Awake NY", "New Era", "The Kooples", "Stone Island Shadow Project", 
  "Superism", "Nike SB", "Asphalt Yacht Club", "Billionaire Boys Club Black Label", "Crooked Tongues", 
  "Public School", "424 Fairfax", "Stampd LA", "Raised by Wolves", "Y-3 by Yohji Yamamoto",

  // Sport & performance
  "Altra Running", "Brooks Trail", "Saucony Originals", "Dynafit", "Inov-8", "Icebug", "Hoka Speedgoat", 
  "Under Armour HeatGear", "Skins Compression", "Reusch", "Mammut Eiger", "Eider", "X-Bionic Effektor",
  "Buff", "Darn Tough Vermont", "Salming", "Odlo", "Helinox", "Zensah", "Garneau", "CamelBak",

  // Outdoor et randonnée
  "Cimalp", "Arpenaz", "Forclaz", "Solognac", "Kalenji", "Quechua", "Simond", "Browning", "Sierra Designs", 
  "Campagnolo (CMP)", "Mountain Equipment", "Rab Neutrino", "Fjällräven Kånken", "Exped", "Big Agnes", 
  "Sea to Summit", "Wild Country", "Petzl", "Primus", "Ortlieb Drybags",

  // Chaussures contemporaines
  "Veja Condor", "Hoka Bondi", "Asics Gel Nimbus", "Meindl", "Hanwag", "Salewa Mountain Trainer", 
  "Danner Light", "Zamberlan", "Scarpa", "La Sportiva Spire", "Mizuno Wave Rider", "Northwave", 
  "Diemme", "Common Projects Achilles", "Repetto", "Gianvito Rossi", "Fratelli Rossetti",

  // Maroquinerie et accessoires
  "Berluti Bags", "Jérôme Dreyfuss", "Sandro Maroquinerie", "Mansur Gavriel Bucket Bag", "Secrid", 
  "Bellroy", "Tumi", "Knomo", "Herschel Supply Co.", "Rains Backpack", "Cabaia", "Eastpak", "Fjällräven Bags", 
  "Millican", "Samsonite", "Thule", "Briggs & Riley", "Bric's", "Rimowa",

  // Joaillerie et montres
  "Daniel Wellington", "MVMT", "Fossil Q", "Shinola", "Longines Conquest", "Mondaine", "Junghans", 
  "Bell & Ross", "Fortis", "Breguet", "Franck Muller", "Corum", "Piaget Polo", "Tudor", 
  "Chopard Mille Miglia", "Nomos Tangente", "Glashütte Original",

  // Mode scandinave
  "Ganni", "Samsøe Samsøe", "Filippa K", "By Malene Birger", "Acne Studios Archive", "Norse Projects", 
  "Wood Wood", "Fjällräven Greenland", "Eytys", "Arket", "Tiger of Sweden", "COS Essentials",

  // Prêt-à-porter hommes
  "SuitSupply", "Boggi Milano", "Charles Tyrwhitt", "Hawes & Curtis", "Turnbull & Asser", "Oliver Spencer", 
  "Orlebar Brown", "Kent & Curwen", "Sunspel", "Hackett London", "Eton Shirts", "Brioni", 
  "Ermenegildo Zegna Couture", "Kiton", "Isaia", "Canali", "Corneliani",

  // Vêtements enfants
  "Cyrillus Enfants", "Mamas & Papas", "Petit Béguin", "Tocoto Vintage", "Emile et Ida", "Bonton", 
  "Billieblush", "Carrément Beau", "Vertbaudet", "Tao Kids", "Catimini Bébé", "The Animals Observatory",

  // Chaussures enfants
  "Geox Kids", "Kickers", "Start Rite", "Stride Rite", "Robeez", "Shoo Pom", "Bisgaard", 
  "Pom d'Api", "Bellamy", "Birkenstock Kids", "Babybotte",

  // Mode japonaise et coréenne
  "Sacai", "Comme des Garçons Homme Plus", "Issey Miyake", "Yohji Yamamoto", "Undercover", 
  "Needles", "Visvim", "Mastermind World", "Wacko Maria", "Ambush", "Ader Error", "Andersson Bell","Disneyland", "Disney Word","Gildan",

  // Cosmétiques & soins
  "Rituals", "L'Occitane", "La Roche-Posay", "Avène", "Bioderma", "Caudalie", "Clarisonic", "Tatcha", 
  "Glow Recipe", "Herbivore Botanicals", "Paula's Choice", "REN Clean Skincare", "Youth to the People", 
  "Olaplex", "Amika", "Bumble and Bumble", "Christophe Robin", "Davines", "Ouai", "Kerastase",

  // Montres connectées et accessoires tech
  "Withings Steel HR", "Garmin Forerunner", "Samsung Galaxy Watch", "Fitbit Versa", "Apple Watch Ultra", 
  "TicWatch", "Fossil Hybrid Smartwatch", "Suunto Core", "Casio Pro Trek", "Huawei Watch GT",

  // Autres catégories lifestyle
  "North Sails", "Penfield", "Hunter Original", "Aigle Footwear", "Sorel Caribou", "K-Way", 
  "Woolrich Arctic Parka", "Canada Goose Expedition", "Belstaff Trialmaster", "Alpha Industries MA-1", 
  "Schott Perfecto", "Filson Tin Cloth", "Barbour Bedale",

  // Prêt-à-porter premium
  "Frame Denim", "Joe Fresh", "Madewell Denim", "Mother Denim", "AGOLDE", "Paige", "Citizens of Humanity", 
  "DL1961", "Rag & Bone Jeans", "Denham", "L'Agence", "AllSaints", "Everlane Modern Basics", "Reiss Tailoring",

  // Autres marques accessoires
  "Longchamp Le Pliage", "Céline Belt Bag", "Prada Galleria", "Gucci Dionysus", "Hermès Birkin", 
  "Chanel Classic Flap", "Louis Vuitton Neverfull", "Fendi Baguette", "Dior Book Tote", "Bottega Veneta Cassette",
  "Jacquemus Le Chiquito", "JW Anderson", "Chloe Faye", "Marc Jacobs Snapshot", "Kate Spade Cameron",
  
  // Chaussures spécifiques
  "Nike Air Max", "Adidas Ultraboost", "New Balance 990", "Vans Old Skool", "Converse Chuck Taylor",
  "Reebok Club C", "Puma Suede", "Saucony Jazz", "Fila Disruptor", "On Cloud", "Salomon Speedcross",
  "Timberland 6-Inch Boots", "Dr. Martens 1460", "Clarks Wallabee", "Birkenstock Arizona", "Crocs Classic",
  
  // Uniformes et spécialités
  "Dickies Workwear", "Carhartt Rugged Flex","UGG", "Blaklader X1900", "Propper Tactical", "5.11 Covert", 
  "Red Kap Industrial", "Bulwark FR", "Hi-Viz", "Caterpillar Earthmovers", "La Sportiva Approach", 
  "Snickers Workwear", "Chef Works Essential Apron","Dockers","NBA"
  ];

  }