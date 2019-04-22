class UserRepo():
    def __init__(self, conn):
        self.conn = conn

    def create_user(self, email='', display_name='', password=''):
        cursor = self.conn.cursor()
        cursor.execute("""
            EXEC Soundfront.CreateUser 
                @Privacy=?,
                @DisplayName=?,
                @Email=?,
                @EnteredPassword=?
        """, 1, display_name, email, password)
        return cursor.fetchone()

    def list_users(self, page, page_size):
        cursor = self.conn.cursor()
        cursor.execute('EXEC Soundfront.ListUser @Page=?, @PageSize=?', page, page_size)
        return cursor.fetchall()

    def user_count(self):
        cursor = self.conn.cursor()
        cursor.execute('EXEC Soundfront.UserCount')
        return cursor.fetchone()[0]

    def get_user(self, id):
        cursor = self.conn.cursor()
        cursor.execute('EXEC Soundfront.GetUser @UserID=?', id)
        return cursor.fetchone()

    def get_user_by_email(self, email):
        cursor = self.conn.cursor()
        cursor.execute('EXEC Soundfront.GetUserByEmail @Email=?', email)
        return cursor.fetchone()

    def remove_user(self, id):
        cursor = self.conn.cursor()
        cursor.execute('EXEC Soundfront.RemoveUser @UserID=?', id)