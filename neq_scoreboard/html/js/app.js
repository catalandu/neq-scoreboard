var streamer;
var jobs;
var users;
var id;

window.addEventListener('message', function(event) {
    var data = event.data
    
    switch (data.type) {
        case 'refresh':
            refreshAll(data);
            break;
        case 'init':
            streamer = data.status
            jobs = data.jobs
            break;
        case 'close':
            close();
            break;
    }
})

$(function() {
    $('html').keyup(function (e) {
        if (e.key === "Escape") {
            close();
        }
    }); 

    $('body').on('click', '.streamer', function() {
        streamer = streamer == 0 ? 1 : 0
        $('.streamer').removeClass(streamer == 0 ? 'enabled' : 'disabled');
        $('.streamer').addClass(streamer == 0 ? 'disabled' : 'enabled');
        $.post('https://neq_scoreboard/streamer', JSON.stringify({streamer: streamer}));
    });

    $('body').on('input', '.search', function() {
        removePlayers();
        
        for (const [key, value] of Object.entries(users)) {
            if (value.id !== id) {
                let str = value.name.toLowerCase();
                let val = this.value.toLowerCase();

                if (str.search(val) >= 0) {
                    addPlayers(value)
                }
            }
        }
    });
})

function refreshAll(data) {
    $('.container').show();

    users = data.users
    id = data.id;

    for (const [key, value] of Object.entries(users)) {
        if (value.id == data.id) {
            addSelf(value);
        } else {
            addPlayers(value)
        }
    }   

    if (data.jobs) {
        updateJobs(data.jobs)
    }
}

function addSelf(value) {
    $('.self').html(`
        <img src='${value.avatar}'>
        <p id="username">${value.name} | ID: ${value.id}</p>
        <p id="ping">Ping: ${value.ping}</p>
        <p id="online">Online: ${value.players}</p>
        <p id="streamer">Streamer mode:</p><div class="streamer ${streamer == 0 ? 'disabled' : 'enabled'}"></div>
    `)
}

function addPlayers(value) {
    $('#users').append(`
        <tr>
            <td>${streamer == 0 ? `<img src="${value.avatar}">` : 'DISABLED'}</td>
            <td>${value.id}</td>
            <td>${value.name}</td>
            <td>${value.ping}</td>
        </tr>
    `)
}

function removePlayers() {
    $('#users').html(`
        <tr>
            <th>Avatar</th>
            <th>ID</th>
            <th>Username</th>
            <th>Ping</th>
        </tr>
    `)
}

function updateOnline(count) {
    $('#online').html('Online: ' + count)
}

function updateJobs(data) {
    $('#jobs').empty();
    
    for (const [key, value] of Object.entries(data)) {
        $('#jobs').append('<th>' + jobs[key].label + ': ' + value + '</th>')
    }
}

function close() {
    $('.container').addClass("off");
    
    setTimeout(() => { 
        removePlayers();
        $('.container').hide();
        $('.container').removeClass("off");
        $.post('https://neq_scoreboard/close');
    }, 500);
}

