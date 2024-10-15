<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Amigos de Viagem</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            color: #333;
            margin: 0;
            padding: 0;
            line-height: 1.6;
        }

        .container {
            width: 80%;
            margin: auto;
            overflow: hidden;
        }

        h1, h2, h3 {
            color: #4b0082;
        }

        header {
            background-color: #4b0082;
            color: #fff;
            padding: 10px 0;
            text-align: center;
        }

        section {
            margin: 20px 0;
            padding: 20px;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        pre {
            background: #f4f4f4;
            padding: 10px;
            border-radius: 5px;
            border-left: 5px solid #4b0082;
            overflow-x: auto;
        }

        .highlight {
            color: #4b0082;
        }

        footer {
            text-align: center;
            margin-top: 20px;
            padding: 10px;
            background-color: #4b0082;
            color: #fff;
        }

        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin: 20px 0;
            background-color: #4b0082;
            color: #fff;
            text-decoration: none;
            border-radius: 5px;
        }

        .btn:hover {
            background-color: #360067;
        }
    </style>
</head>
<body>

<header>
    <h1>Amigos de Viagem 🚗💬</h1>
    <p>Seu aplicativo de viagens em grupo, desenvolvido em Flutter!</p>
</header>

<div class="container">

    <section>
        <h2>🎯 Funcionalidades</h2>
        <ul>
            <li><span class="highlight">Criação de Grupos:</span> Crie grupos com seus amigos para planejar rotas de viagem.</li>
            <li><span class="highlight">Rotas em Tempo Real:</span> O líder do grupo define a rota, e todos os membros podem segui-la em seus dispositivos.</li>
            <li><span class="highlight">Adição de Amigos:</span> Conecte-se com amigos e adicione-os aos seus grupos de viagem.</li>
            <li><span class="highlight">Chat de Grupo:</span> Comunique-se com os membros do grupo através de um chat integrado.</li>
            <li><span class="highlight">Mapa Interativo:</span> Veja a rota no mapa e siga o caminho definido.</li>
            <li><span class="highlight">Integração Firebase:</span> Grupos e localizações são gerenciados via Firebase, garantindo dados em tempo real.</li>
        </ul>
    </section>

    <section>
        <h2>🚀 Tecnologias Utilizadas</h2>
        <ul>
            <li><span class="highlight">Flutter</span>: Framework para desenvolvimento mobile multiplataforma.</li>
            <li><span class="highlight">Dart</span>: Linguagem de programação utilizada pelo Flutter.</li>
            <li><span class="highlight">Firebase</span>: Usado para autenticação, gerenciamento de grupos e sincronização de dados.</li>
            <li><span class="highlight">flutter_map</span>: Biblioteca para exibição de mapas no Flutter.</li>
        </ul>
    </section>

    <section>
        <h2>📲 Telas do Aplicativo</h2>
        <ul>
            <li><span class="highlight">Tela de Login/Cadastro</span>: Interface para autenticação de usuários.</li>
            <li><span class="highlight">Tela Inicial</span>: Escolha entre criar ou entrar em um grupo existente.</li>
            <li><span class="highlight">Mapa</span>: Mapa interativo com a rota definida.</li>
            <li><span class="highlight">Chat</span>: Conversa em tempo real com os membros do grupo.</li>
            <li><span class="highlight">Lista de Amigos</span>: Gerencie seus amigos e adicione-os aos grupos.</li>
        </ul>
    </section>

    <section>
        <h2>💡 Funcionalidades Futuras</h2>
        <ul>
            <li>Melhorar a precisão do mapa e da localização dos usuários.</li>
            <li>Adicionar suporte para diferentes tipos de rotas (ex. evitar pedágios).</li>
            <li>Melhorar a interface de usuário com animações mais fluídas.</li>
            <li>Implementar notificações push para avisar sobre novas mensagens no chat.</li>
        </ul>
    </section>

    <section>
        <h2>🤝 Contribuições</h2>
        <p>Contribuições são bem-vindas! Se você deseja sugerir melhorias ou corrigir bugs, sinta-se à vontade para abrir uma <em>issue</em> ou enviar um <em>pull request</em>.</p>
    </section>

    <section>
        <h2>📝 Licença</h2>
        <p>Este projeto está licenciado sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.</p>
    </section>

    <footer>
        <p>📧 <a href="mailto:dev.ssgobin@gmail.com" class="btn">Entre em contato</a></p>
        <p>🔗 <a href="https://www.linkedin.com/in/jo%C3%A3o-vitor-sgobin-4a4556211/" class="btn">LinkedIn</a></p>
    </footer>
</div>

</body>
</html>
