// If you use Config.ExtraData is event.data.other all data gets send in a table :)


const s_click = new Audio('./sounds/click.mp3');
const s_hover = new Audio('./sounds/hover.wav');
const s_open = new Audio('./sounds/transition.ogg');

s_click.volume = 0.2;
s_hover.volume = 0.2;
s_open.volume = 0.1;

$(document).keydown(function (e) {
	if (e.key === 'Escape') {
		$('.bg').removeClass('open');
		fetch('closeMenu');
		s_open.currentTime = '0';
		s_open.play();
	}
});

function numberWithCommas(x) {
	var parts = x.toString().split('.');
	parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, '.');
	return parts.join(',');
}

$('document').ready(function () {
	window.addEventListener('message', function (event) {
		switch (event.data.action) {
			case 'OpenMenu':
				$('.bg').addClass('open');
				$('#name').text(event.data.name);
				$('#job-name').text(event.data.job);

				$('#text-cash').text(numberWithCommas(event.data.cash) + '$');
				$('#text-bank').text(numberWithCommas(event.data.bank) + '$');

				if (event.data.discord) {
					$('.discord').attr('url', event.data.discord);
				}

				if (event.data.instagram) {
					$('.instagram').attr('url', event.data.instagram);
				} else {
					$('.instagram').hide();
				}

				if (event.data.twitter) {
					$('.twitter').attr('url', event.data.twitter);
				} else {
					$('.twitter').hide();
				}

				if (event.data.youtube) {
					$('.youtube').attr('url', event.data.youtube);
				} else {
					$('.youtube').hide();
				}

				if (event.data.website) {
					const regex = /^(?:https?:\/\/)?(?:www\.)?([^\/]+)/i;
					const domain = event.data.website.match(regex)[1];
					const formattedWebsite = domain.startsWith('www.')
						? domain.slice(4)
						: domain;
					// Use formattedWebsite as needed

					$('.web').attr('url', event.data.website).text(formattedWebsite);
				} else {
					$('.web').hide();
				}

				$('.players .d-data').text(
					event.data.usersOnline + '/' + event.data.maxPlayers
				);
				$('.police .d-data').text(
					event.data.PoliceAvailable ? 'Available' : 'No Available'
				);

				s_open.currentTime = '0';
				s_open.play();
				break;
		}
	});
});

$(document).on('mouseenter', '.btn-sound', function () {
	s_hover.currentTime = '0';
	s_hover.play();
});

$(document).on('click', '.btn-sound', function () {
	s_click.currentTime = '0';
	s_click.play();
});

$(document).on('click', '.btn-menu', function () {
	const action = $(this).attr('action');
	switch (action) {
		case 'map':
			fetch('openMap');
			$('.bg').removeClass('open');
			fetch('closeMenu');

			break;

		case 'settings':
			fetch('openSettings');
			$('.bg').removeClass('open');
			fetch('closeMenu');

			break;

		case 'quit':
			OpenModal();
			break;
	}
});

function OpenModal() {
	$('body').append(`
    <div class="c-modal fadeIn">
       <div class="modal-block">
            <div class="modal-content scale-in-2" style="width: max-content">

                <div class="modal-body">
					Do you want to exit the game?
                </div>
                <div class="modal-footer">
                    <button class="btn-modal btn-sound" onclick='quitGame()'>
						Yes</button>
                    <button class="btn-cancel btn-sound" onclick='CloseModal()'>No</button>
                </div>
            </div>
        </div>
    </div>
    `);
}

function quitGame() {
	fetch('exitGame');
}

function CloseModal() {
	$('.c-modal .modal-block .modal-content')
		.removeClass('scale-in-2')
		.addClass('scale-out-2');
	$('.c-modal')
		.removeClass('fadeIn')
		.fadeOut(500, function () {
			$(this).remove();
		});
}

$(document).on('click', '.link', function () {
	const url = $(this).attr('url');
	if (url) {
		window.invokeNative('openUrl', url);
	}
});

function fetch(event, data) {
	return $.post(
		'https://origen_pausemenu/' + event || {},
		JSON.stringify(data)
	).promise();
}
