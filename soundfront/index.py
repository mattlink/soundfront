from flask import (Blueprint, render_template, current_app, request)
from .album import AlbumRepo
from .song import SongRepo

bp = Blueprint('index', __name__, url_prefix='/')

@bp.route('/', methods=['GET'])
def index():
	frame = request.args.get('frame')
	if frame == 'year' or frame is None:
		frame = 365
	elif frame == 'month':
		frame = 30
	elif frame == 'week':
		frame = 7
	elif frame == 'day':
		frame = 1

	album_repo = current_app.config['album']
	recent_albums = album_repo.recent_albums(page=1, page_size=10)
	top_rated_albums = album_repo.get_top_rated_albums(frame=frame)
	return render_template('index.html', recent_albums=recent_albums, top_rated_albums=top_rated_albums)

@bp.route('/search', methods=['GET','POST'])
def search():
	album_repo = current_app.config['album']
	song_repo = current_app.config['song']

	search = request.form['searchform'] + '%'

	albums = album_repo.searchfor_album(search)
	songs = song_repo.search_for_song(search)

	searchtext = search[:-1]
	return render_template('search.html', albums=albums, songs=songs, searchtext=searchtext)
