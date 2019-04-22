from flask import (Blueprint, render_template, current_app)
from .album import AlbumRepo

bp = Blueprint('index', __name__, url_prefix='/')

@bp.route('/', methods=['GET'])
def index():
	album_repo = current_app.config['album']
	albums = album_repo.recent_albums(page=1, page_size=10)
	# TODO: add Top Rated Albums to homepage
	return render_template('index.html', albums=albums)

