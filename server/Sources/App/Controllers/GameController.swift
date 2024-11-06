//
//  GameController..swift
//
//
//  Created by Владислав Жуков on 27.08.2024.
//

import Vapor

final class GameController {
    
    struct NewGameResponse: Content {
        let id: String
        let hostId: String
    }
    
    struct JoinRequest: Content {
        let gameId: String
        let player: Game.Player
    }
    
    func create(req: Request) throws -> EventLoopFuture<Response> {
        let host = try req.content.decode(Game.Player.self, as: .json)
        let id = "newgame"//UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let state = Game.State(id: id, host: host)
        let game = Game(id: id, host: host, state: state)
        
        return try req.application.gameService.add(game: game, on: req).map {
            let data = try! JSONEncoder().encode(state)
            return Response(status: .ok, body: .init(data: data))
        }
    }
    
    func game(req: Request) throws -> EventLoopFuture<Game.State> {
        let id = req.parameters.get("id")!
        
        return try req.application.gameService.game(by: id, on: req)
    }
    
    func games(req: Request) throws -> EventLoopFuture<[String]> {
        return try req.application.gameService.games(on: req)
    }
    
    func join(req: Request) throws -> EventLoopFuture<Game.State> {
        let join = try req.content.decode(JoinRequest.self, as: .json)
        
        return try req.application.gameService.join(gameId: join.gameId, player: join.player, on: req)
    }
        
    func players(req: Request) throws -> EventLoopFuture<[Game.Player]> {
        let id = req.parameters.get("id")!
        
        return try req.application.gameService.players(gameId: id, on: req)
    }
}

extension GameController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let games = routes.grouped("api", "games")
        
        games.post("create", use: create)
        games.post("join", use: join)
        
        games.get("game", ":id", use: game)
        games.get("games", use: self.games)
        games.get("players", ":id", use: players)
    }
}

final class Words {
    static func prepareWords() -> [Game.Word] {
        var colors = Words.colors()
        return words().map {
            let index = (0..<colors.count).randomElement()!
            let color = colors.remove(at: index)
            return Game.Word(word: $0, color: Game.WColor(rawValue: color)!)
        }
    }
    
    static func colors() -> [Int] {
        let values = [
            [1, 1, 2, 2, 0, 3, 0, 0, 1, 2, 1, 2, 1, 0, 2, 0, 1, 2 ,1, 2, 0, 2, 1, 2, 0], //1-8 2-9
            [1, 1, 2, 2, 0, 3, 2, 0, 2, 2, 1, 2, 1, 0, 0, 0, 1, 2 ,1, 2, 0, 1, 1, 1, 0], //1-9 2-8
            [1, 1, 0, 0, 2, 0, 2, 0, 1, 2, 1, 2, 1, 3, 2, 0, 1, 2 ,0, 2, 1, 2, 1, 2, 0], //1-8 2-9
            [1, 0, 2, 0, 1, 1, 2, 0, 2, 2, 1, 2, 1, 3, 0, 1, 0, 2 ,1, 0, 2, 1, 1, 0, 2]  //1-9 2-8
        ]
        
        return values.randomElement()!.shuffled()
    }
    
    static func words() -> [String] {
        ["агент", "акт", "ак­ция", "аль­бом", "ам­фи­бия", "ап­па­рат", "ба­боч­ка", "ба­за", "банк", "ба­ня", "бар", "ба­рьер", "бас­сейн", "ба­та­рея", "баш­ня", "бе­лок", "бе­рё­за", "би­лет", "бир­жа", "блок", "боб", "бо­е­вик", "боль­ни­ца", "бом­ба", "борт", "бо­ти­нок", "боч­ка", "брак", "бу­ма­га", "бу­тыл­ка", "бык", "бы­чок", "бюст", "вал", "ведь­ма", "ве­нец", "вер­то­лёт", "верфь", "ве­тер", "вил­ка", "ви­рус", "вис­ки", "во­да", "вождь", "вол­на", "вор", "во­рот", "газ", "га­зель", "га­лоп", "гвоздь", "ги­гант", "го­ло­ва", "гольф", "гра­нат", "гре­бень", "гриф", "гру­ша", "гу­ба", "гу­се­ни­ца", "да­ма", "да­ча", "двор", "двор­ник", "диск", "долг", "дра­кон", "дробь", "ды­ра", "еди­но­рог", "жи­ла", "за­бор", "за­вод", "за­лив", "за­мок", "за­яц", "звез­да", "зеб­ра", "зем­ля", "змей", "зо­ло­то", "зо­на", "иг­ла", "ик­ра", "ин­сти­тут", "ка­ба­чок", "ка­бинет", "кадр", "ка­зи­но", "ка­мень", "ка­ме­ра", "ка­нал", "ка­ра­ул", "кар­лик", "кар­та", "ка­ток", "ка­ша", "кен­гу­ру", "кен­тавр", "кет­чуп", "ки­ви", "кисть", "кит", "класс", "клет­ка", "ключ", "кол", "ко­ло­да", "ко­лон­на", "коль­цо", "ко­рень", "ко­роле­ва", "ко­роль", "ко­ро­на", "ко­са", "ко­сяк", "кош­ка", "кран", "кре­пость", "кро­лик", "кро­на", "крош­ка", "круг", "кры­ло", "ку­лак", "курс", "ла­дья", "ла­зер", "ла­ма", "лас­ка", "лев", "ле­ген­да", "лёд", "лес", "ли­му­зин", "ли­ния", "ли­па", "ли­ра", "ли­цо", "ло­же", "ло­пат­ка", "лот", "ло­шадь", "лук", "ман­дарин", "мар­ка", "марш", "мас­ло", "мат", "мед­ведь", "мик­ро­скоп", "ми­на", "мир", "мол­ния", "моль", "мор­ковь", "мо­тив", "муш­ка", "на­лёт", "на­ряд", "небо­скрёб", "но­мер", "нор­ка", "но­та", "ня­ня", "об­лом", "об­ра­зо­ва­ние", "об­рез", "ов­сян­ка", "Олимп", "опе­ра", "ор­ган", "ор­ден", "орёл", "ось­ми­ног", "оч­ки", "па­де­ние", "па­на­ма", "па­ра", "па­ра­шют", "парк", "пар­тия", "па­трон", "па­ук", "пе­ре­вод", "пе­ро", "пе­чать", "пи­лот", "пи­рат", "пи­сто­лет", "пла­та", "пла­тье", "плом­ба", "пло­щадь", "по­вар", "по­гон", "под­ко­ва", "подъ­ём", "пол", "по­ле", "пом­па", "порт", "по­сол", "пост", "по­ток", "поч­ка", "пра­во", "пред­ло­же­ние", "при­зрак", "прин­цес­са", "при­ше­лец", "проб­ка", "про­вод­ник", "про­кат", "про­спект", "путь", "Пуш­кин", "пя­та­чок", "раз­вод", "раз­во­рот", "раз­ряд", "рас­твор", "риф", "ро­бот", "рог", "род", "рок", "ру­баш­ка", "руб­ка", "ру­лет­ка", "руч­ка", "ры­ба", "рысь", "ры­царь", "са­лют", "сан­тех­ник", "са­чок", "све­ча", "сви­де­тель", "сек­рет", "сеть", "скат", "сна­ряд", "снег", "сне­го­вик", "со­ба­ка", "сол­дат", "соль", "сплав", "спут­ник", "ссыл­ка", "став­ка", "ста­ди­он", "ста­нок", "ствол", "стек­ло", "сте­на", "стол", "стоп­ка", "стре­ла", "строч­ка", "стру­на", "стул", "съезд", "таз", "так­са", "такт", "та­нец", "та­рел­ка", "те­ле­га", "те­ле­скоп", "ти­тан", "ток", "тре­уголь­ник", "тру­ба", "тур", "удар­ник", "узел", "ут­ка", "учё­ный", "учи­тель", "фа­кел", "фа­лан­га", "фин­ка", "флей­та", "хло­пок", "ци­линдр", "честь", "шай­ба", "шай­ка", "шар", "шах", "шаш­ка", "шиш­ка", "шо­ко­лад", "шпа­гат", "шпи­он", "шу­ба", "эльф", "яб­ло­ко", "язык", "яч­мень"].randomSample(count: 25)
    }
}
