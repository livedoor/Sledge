-- $Id: sessions.sql,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
CREATE TABLE sessions (
       id char(32) not null primary key,
       a_session mediumtext,
       timestamp timestamp
);
