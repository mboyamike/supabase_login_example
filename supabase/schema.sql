-- Create tables
CREATE TABLE public.words (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    word TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    deleted_at TIMESTAMPTZ
);

-- Enable Row Level Security
ALTER TABLE public.words ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable users to view their own data only"
ON public.words
FOR SELECT
TO authenticated
USING (
  ((auth.uid() = user_id) AND (is_active = true))
);

CREATE POLICY "Enable users to insert their own data only"
ON public.words
FOR INSERT
TO authenticated
WITH CHECK (
  (auth.uid() = user_id)
);

CREATE POLICY "Enable users to update their own data only"
ON public.words
FOR UPDATE
TO authenticated
USING (
  (auth.uid() = user_id)
)
WITH CHECK (
  (auth.uid() = user_id)
);


CREATE INDEX words_user_id_idx ON public.words (user_id);
CREATE INDEX words_is_active_idx ON public.words (is_active);